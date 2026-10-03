;;; eh-today.el --- One-page Org plan for today  -*- lexical-binding: t -*-

;; `eh-today' opens (creating if needed) today's page,
;; ~/org/days/YYYY-MM-DD.org.  A new page carries over the unchecked items and
;; the "Where I left off" note from the most recent earlier page.

(require 'subr-x)

(defvar eh-today-directory (expand-file-name "~/org/days/")
  "Directory holding one Org file per day.")

(defun eh-today--file (&optional time)
  "Return the page file name for TIME (default now)."
  (expand-file-name (format-time-string "%Y-%m-%d.org" time) eh-today-directory))

(defun eh-today--previous-file ()
  "Return the newest page before today's, or nil."
  (let ((today (file-name-nondirectory (eh-today--file))))
    (car (last (seq-filter
                (lambda (f) (string< (file-name-nondirectory f) today))
                (directory-files eh-today-directory t
                                 "\\`[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\.org\\'"))))))

(defun eh-today--section (text heading)
  "Return the body of the \"* HEADING\" section in TEXT, trimmed."
  (when (string-match
         (format "^\\* %s\n\\(\\(?:.*\n?\\)*?\\)\\(?:^\\* \\|\\'\\)"
                 (regexp-quote heading))
         text)
    (string-trim (match-string 1 text))))

(defun eh-today--carry-over (file)
  "Return (LEFT-OFF . UNCHECKED-LINES) from the page FILE."
  (let ((text (with-temp-buffer (insert-file-contents file) (buffer-string))))
    (cons (eh-today--section text "Where I left off")
          (seq-filter (lambda (l) (string-match-p "\\`- \\[ \\] +[^ ]" l))
                      (split-string text "\n")))))

;; Keys that exist only on a day page (a minor mode, so they never leak):
;;   C-c p  park a stray thought without leaving the place you are working
;;   C-c x  mark the checkbox item on this line done and move it to "Done"
(defvar eh-today-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c p") #'eh-today-park)
    (define-key map (kbd "C-c x") #'eh-today-done)
    map))

(define-minor-mode eh-today-mode
  "Keys for a one-page day plan."
  :lighter " Today"
  :keymap eh-today-mode-map)

(defun eh-today--section-end (heading)
  "Return the position just after the last text of the \"* HEADING\" section.
For an empty section that is the end of the heading line."
  (save-excursion
    (goto-char (point-min))
    (unless (re-search-forward
             (format "^\\* %s$" (regexp-quote heading)) nil t)
      (user-error "No \"%s\" section on this page" heading))
    (forward-line 1)
    (goto-char (if (re-search-forward "^\\* " nil t)
                   (match-beginning 0)
                 (point-max)))
    (skip-chars-backward " \t\n")
    (point)))

(defun eh-today-park (thought)
  "Add THOUGHT to the Parking lot without moving point or the window."
  (interactive "sPark: ")
  (when (string-blank-p thought) (user-error "Nothing to park"))
  (save-excursion
    (goto-char (eh-today--section-end "Parking lot"))
    (insert "\n- " (string-trim thought)))
  (save-buffer)
  (message "Parked: %s" (string-trim thought)))

(defun eh-today-done ()
  "Check off the item on this line and move it to the Done section."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (unless (looking-at "[ \t]*- \\[ \\] +\\(.+\\)$")
      (user-error "Not on an unchecked item"))
    (let ((text (match-string 1)))
      (delete-region (line-beginning-position)
                     (min (point-max) (1+ (line-end-position))))
      (goto-char (eh-today--section-end "Done"))
      (insert "\n- [X] " text)
      (message "Done: %s" text)))
  (save-buffer))

;; The title text starts at the left; a leading space whose :align-to is
;; `center' minus half the text's pixel width tracks the window size by itself.
(defun eh-today--center-title ()
  "Center the \"#+TITLE:\" text on its line, whatever the window width."
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward "^#\\+TITLE: *" nil t)
      (let* ((beg (match-end 0))
             (end (line-end-position))
             (win (get-buffer-window (current-buffer)))
             (px (and win (> end beg)
                      (car (window-text-pixel-size win beg end)))))
        (mapc #'delete-overlay
              (seq-filter (lambda (o) (overlay-get o 'eh-today-title))
                          (overlays-in (point-min) (1+ end))))
        (when px
          (let ((o (make-overlay beg beg)))
            (overlay-put o 'eh-today-title t)
            (overlay-put o 'before-string
                         (propertize " " 'display
                                     `(space :align-to (- center (,(/ px 2))))))))))))

(defun eh-today--template ()
  "Insert the skeleton for a new page, carrying over from the last one."
  (let* ((prev (eh-today--previous-file))
         (carry (and prev (eh-today--carry-over prev)))
         (left (car carry))
         (todo (cdr carry)))
    (insert (format-time-string "#+TITLE: %A, %B %-d, %Y\n\n"))
    (insert "* Right now\n\n")
    (insert "* Where I left off\n")
    (when (and left (not (string-empty-p left)))
      (insert (format "(from %s)\n%s\n"
                      (file-name-base prev) left)))
    (insert "\n* Top 3\n- [ ] \n- [ ] \n- [ ] \n\n")
    (when todo
      (insert "* Carried over\n" (string-join todo "\n") "\n\n"))
    ;; org-pretty-table draws the corners from the rules: a rule as the very
    ;; first line gives ┌─┬─┐, one between rows gives ├─┼─┤, and a rule as the
    ;; very last line gives └─┴─┘.  Keep all three, and no blank line inside.
    (insert "* Schedule\n"
            "|------+------+------|\n"
            "| Time | What | Done |\n"
            "|------+------+------|\n"
            "|      |      |      |\n"
            "|      |      |      |\n"
            "|------+------+------|\n\n")
    (insert "* Parking lot\n\n")
    (insert "* Done\n")))

;;;###autoload
(defun eh-today ()
  "Open today's one-page plan, creating it from the template if needed."
  (interactive)
  (let ((file (eh-today--file)))
    (make-directory eh-today-directory t)
    (find-file file)
    (when (zerop (buffer-size))
      (eh-today--template)
      (save-buffer))
    (org-mode)
    ;; org-modern hides every star; org-pretty-table (not org-modern) draws
    ;; the tables.
    (setq-local org-modern-hide-stars t
                org-modern-star nil
                org-modern-table nil
                ;; A round bullet; the default en dash looks like a tilde in
                ;; Lucida Casual.
                org-modern-list '((?+ . "•") (?- . "•") (?* . "•"))
                ;; Hide "#+TITLE:" entirely; other keywords lose only "#+".
                org-modern-keyword '(("title" . "") (t . t)))
    (when (require 'org-modern nil t)
      (org-modern-mode 1))
    (when (require 'org-pretty-table nil t)
      (org-pretty-table-mode 1)
      ;; jit-lock runs the mode's function before font-lock, which then wipes
      ;; its glyphs; move it to the end of the list.
      (remove-hook 'jit-lock-functions #'org-pretty-table-propertize-region t)
      (add-hook 'jit-lock-functions #'org-pretty-table-propertize-region t t))
    (when (require 'wps-face-mode nil t)
      (wps-face-mode 1))
    (eh-today-mode 1)
    (eh-today--center-title)
    (goto-char (point-min))
    (re-search-forward "^\\* Right now\n" nil t)))

(provide 'eh-today)
;;; eh-today.el ends here
