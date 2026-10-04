;;; eh-separators.el --- Save wave separators as files  -*- lexical-binding: t -*-

;; `eh-separators-export' writes the wave separators the mode line draws on the
;; fly (see `eh-mode-line-wave-image') to ~/.emacs.d/eh/separators/NAME/ as
;; .xpm files, at the current bar height.  Sets already saved there:
;;   orange  #EEB422 (DarkGoldenrod2, spaceline's highlight colour)
;;   yellow  #F4D43B
;; To use a set's colour live:  (set-face-background 'spaceline-highlight-face "#F4D43B")

(require 'eh-mode-line)

(defconst eh-separators-directory
  (expand-file-name "separators/" (file-name-directory (or load-file-name buffer-file-name))))

(defconst eh-separators--bar-colors
  '((powerline-active1 . "#383838")     ; grey22
    (powerline-active2 . "#666666")     ; grey40
    (mode-line         . "#292923"))
  "The neutral colours the waves meet, as hex, so no display is needed to read them.")

(defconst eh-separators--pairs
  ;; name, direction, start colour (:hl = the set's colour), end colour
  '(("left-active-1"    "right" :hl powerline-active1)
    ("left-active-2"    "right" powerline-active1 :hl)
    ("left-active-3"    "right" :hl mode-line)
    ("minor-mode-right" "right" :hl powerline-active2)
    ("minor-mode-left"  "left"  :hl powerline-active2))
  "Separators that touch the highlight colour.")

(defun eh-separators--hex-rgb (hex)
  "HEX like \"#rrggbb\" as (R G B) in 0-255."
  (mapcar (lambda (i) (string-to-number (substring hex i (+ i 2)) 16)) '(1 3 5)))

(defun eh-separators-export (name color)
  "Save the highlight-colour waves, drawn in hex COLOR, as eh/separators/NAME/*.xpm."
  (interactive "sSet name: \nsHighlight colour (#rrggbb): ")
  (let ((dir (expand-file-name (concat name "/") eh-separators-directory)))
    (make-directory dir t)
    (clrhash eh-mode-line--wave-cache)
    (cl-letf (((symbol-function 'eh-mode-line--rgb) #'eh-separators--hex-rgb))
      (dolist (p eh-separators--pairs)
        (pcase-let ((`(,id ,direction ,sf ,ef) p))
          (let* ((col (lambda (f) (if (eq f :hl) color (cdr (assq f eh-separators--bar-colors)))))
                 (img (get-text-property
                       0 'display
                       (eh-mode-line-wave-image direction (funcall col sf) (funcall col ef)))))
            (with-temp-file (expand-file-name (concat id ".xpm") dir)
              (insert (plist-get (cdr img) :data)))))))
    (clrhash eh-mode-line--wave-cache)   ; don't leave hex-keyed images behind
    (message "Saved %d separators to %s" (length eh-separators--pairs) dir)))

(provide 'eh-separators)
;;; eh-separators.el ends here
