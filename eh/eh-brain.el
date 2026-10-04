;;; eh-brain.el --- "Brain" mode-line segment: what I'm doing right now  -*- lexical-binding: t -*-

;; A clickable spaceline segment at the right end of the mode line.  It shows
;; the first line under "* Right now" on today's page (see eh-today.el), and
;; mouse-1 opens that page.
;;
;; The label is the word "Brain" until a side-profile brain icon is saved as
;; eh/brain-icon.png (transparent PNG); then the icon replaces the word.
;; Load this before `spaceline-all-the-icons-theme' runs and pass the segment:
;;   (spaceline-all-the-icons-theme 'eh-brain)

(require 'spaceline)
(require 'eh-today)

(defconst eh-brain--icon-file
  (expand-file-name "brain-icon.png"
                    (file-name-directory (or load-file-name buffer-file-name)))
  "Optional icon; the word \"Brain\" is shown when it does not exist.")

(defface eh-brain
  '((t :background "#c24577" :foreground "#ffe8f0" :weight bold))
  "Face of the Brain mode-line segment: pink."
  :group 'mode-line)

(defvar eh-brain-max-width 48
  "Longest \"Right now\" text shown in the mode line; the tooltip has it all.")

(defun eh-brain--right-now ()
  "Return the first non-blank line under \"* Right now\" on today's page, or nil."
  (let* ((file (eh-today--file))
         (buf (find-buffer-visiting file))
         (text (cond (buf (with-current-buffer buf (buffer-string)))
                     ((file-readable-p file)
                      (with-temp-buffer (insert-file-contents file) (buffer-string)))))
         (body (and text (eh-today--section text "Right now"))))
    (and body (not (string-empty-p body))
         (car (split-string body "\n" t "[ \t]+")))))

(defun eh-brain--label ()
  "The icon if there is one and we can draw it, else the word \"Brain\"."
  (if (and (display-images-p) (file-exists-p eh-brain--icon-file))
      (eh-mode-line-python-image
       (max 12 (round (* 0.7 (frame-char-height))))
       (face-background 'eh-brain nil t)
       eh-brain--icon-file)
    "Brain"))

(defun eh-brain--cap (dir)
  "Wave end cap in direction DIR between the pink and the bar around it."
  (let ((pink (face-background 'eh-brain nil t))
        (bar (face-background 'powerline-active2 nil t)))
    (if (and (display-images-p) (fboundp 'eh-mode-line-wave-image))
        (eh-mode-line-wave-image dir pink bar)
      "")))

(spaceline-define-segment eh-brain
  "Brain icon (or word) plus today's \"Right now\" line; click to open the page.
Drawn only in the selected window, with wave caps like the other segments."
  (when active
    (let* ((now (eh-brain--right-now))
           (short (and now (truncate-string-to-width now eh-brain-max-width nil nil "…")))
           (text (concat " " (eh-brain--label) (and short (concat "  " short)) " ")))
      (concat
       (eh-brain--cap "left")
       (propertize text
                   'face 'eh-brain
                   'help-echo (or now "No \"Right now\" yet -- click to open today's page")
                   'mouse-face (spaceline-all-the-icons--highlight)
                   'local-map (make-mode-line-mouse-map 'mouse-1 #'eh-today))
       (eh-brain--cap "right"))))
  :tight t)

(provide 'eh-brain)
;;; eh-brain.el ends here
