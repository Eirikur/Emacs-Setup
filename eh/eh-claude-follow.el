;;; eh-claude-follow.el --- follow Claude Code's edits in a side window -*- lexical-binding: t; -*-

;; After every Edit/Write, a Claude Code hook script calls `eh/claude-follow'
;; through emacsclient.  It shows the change in a right-hand side window
;; WITHOUT selecting that window, raising the frame or touching the window
;; you are working in.  The window shows either the diff of the change or the
;; plain file at the changed line; `eh/claude-follow-toggle' (C-c v, bound in
;; init.el) flips between the two.  The choice is sticky: it stays until you
;; flip it again.  Clicking in any window makes it the only one (section 6 of
;; init.el), which also dismisses this one.

(require 'diff-mode)
(require 'pulse)

(defvar eh/claude-follow-view 'diff
  "What the follow window shows: `diff' or `file'.")

(defvar eh/claude-follow--file nil "Absolute name of the file last changed.")
(defvar eh/claude-follow--line 1 "First changed line in that file.")
(defvar eh/claude-follow--end 1 "Last changed line in that file.")
(defvar eh/claude-follow--diff nil "Unified diff of the last change, or nil.")

(defconst eh/claude-follow-diff-buffer "*Claude diff*")

(defun eh/claude-follow--display (buf)
  "Show BUF in the follow window, without selecting it.  Return the window."
  (display-buffer buf '(display-buffer-in-side-window
                        (side . right) (slot . 0) (window-width . 0.4))))

(defun eh/claude-follow--show-diff ()
  (let ((buf (get-buffer-create eh/claude-follow-diff-buffer))
        (pos 1))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert eh/claude-follow--diff))
      (unless (derived-mode-p 'diff-mode)
        (diff-mode))
      (setq buffer-read-only t)
      (goto-char (point-min))
      (when (re-search-forward "^@@" nil t)
        (setq pos (line-beginning-position))))
    (let ((win (eh/claude-follow--display buf)))
      (when win
        (set-window-start win (point-min))
        (set-window-point win pos)))))

(defun eh/claude-follow--show-file ()
  (unless (file-regular-p eh/claude-follow--file)
    (user-error "No such file: %s" eh/claude-follow--file))
  (let* ((file eh/claude-follow--file)
         (buf (find-file-noselect file t))
         (stale (not (verify-visited-file-modtime buf))))
    (with-current-buffer buf
      (cond ((and stale (not (buffer-modified-p)))
             (revert-buffer t t t))
            (stale
             (message "Claude changed %s on disk; your buffer has unsaved edits"
                      (file-name-nondirectory file)))))
    (let ((win (eh/claude-follow--display buf)))
      (when win
        (with-current-buffer buf
          (save-restriction
            (widen)
            (save-excursion
              (goto-char (point-min))
              (forward-line (1- eh/claude-follow--line))
              (let ((beg (point)))
                (set-window-point win beg)
                (set-window-start win (progn (forward-line -6) (point)) t)
                (goto-char beg)
                (forward-line (- eh/claude-follow--end eh/claude-follow--line -1))
                (pulse-momentary-highlight-region beg (point))))))))))

(defun eh/claude-follow--show ()
  (if (and (eq eh/claude-follow-view 'diff) eh/claude-follow--diff)
      (eh/claude-follow--show-diff)
    (eh/claude-follow--show-file)))

(defun eh/claude-follow (file line end diff)
  "Show a change to FILE (lines LINE..END) in the follow window.
DIFF is the unified diff of the change, or nil when there isn't one.
Called by the Claude Code hook; never signals."
  (condition-case err
      (progn
        (setq eh/claude-follow--file file
              eh/claude-follow--line line
              eh/claude-follow--end end
              eh/claude-follow--diff diff)
        (eh/claude-follow--show))
    (error (message "eh/claude-follow: %s" (error-message-string err)))))

(defun eh/claude-follow-toggle ()
  "Flip the follow window between the diff and the plain file."
  (interactive)
  (unless eh/claude-follow--file
    (user-error "Nothing from Claude to show yet"))
  (setq eh/claude-follow-view (if (eq eh/claude-follow-view 'diff) 'file 'diff))
  (when (and (eq eh/claude-follow-view 'diff) (not eh/claude-follow--diff))
    (setq eh/claude-follow-view 'file)
    (message "No diff for that change; showing the file"))
  (eh/claude-follow--show))

(provide 'eh-claude-follow)
;;; eh-claude-follow.el ends here
