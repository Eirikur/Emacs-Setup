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

(defun eh-today--template ()
  "Insert the skeleton for a new page, carrying over from the last one."
  (let* ((prev (eh-today--previous-file))
         (carry (and prev (eh-today--carry-over prev)))
         (left (car carry))
         (todo (cdr carry)))
    (insert (format-time-string "#+TITLE: %A %Y-%m-%d\n\n"))
    (insert "* Right now\n\n")
    (insert "* Where I left off\n")
    (when (and left (not (string-empty-p left)))
      (insert (format "(from %s)\n%s\n"
                      (file-name-base prev) left)))
    (insert "\n* Top 3\n- [ ] \n- [ ] \n- [ ] \n\n")
    (when todo
      (insert "* Carried over\n" (string-join todo "\n") "\n\n"))
    (insert "* Schedule\n"
            "| Time | What | Done |\n"
            "|------+------+------|\n"
            "|      |      |      |\n"
            "|      |      |      |\n\n")
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
    (when (require 'org-pretty-table nil t)
      (org-pretty-table-mode 1))
    (when (require 'wps-face-mode nil t)
      (wps-face-mode 1))
    (goto-char (point-min))
    (re-search-forward "^\\* Right now\n" nil t)))

(provide 'eh-today)
;;; eh-today.el ends here
