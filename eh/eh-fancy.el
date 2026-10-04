;;; eh-fancy.el --- "Fancy eirikur mode" for Org files  -*- lexical-binding: t -*-

;; `eh-fancy-mode' turns on a stack of look-and-feel pieces in an Org buffer:
;; org-modern, org-pretty-table, wps-face-mode, a centered title, and
;; (optionally) space-doc-mode.  It starts itself from `org-mode-hook' when
;; the file asks for it, so it works however the file was opened:
;;
;;   - the file has the tag WPS:      #+FILETAGS: :WPS:
;;   - or it is under one of `eh-fancy-directories' (the day pages are)
;;
;; Per-file choices are plain Org keywords, read as data and never evaluated,
;; so no file-local-variable security prompt:
;;
;;   #+WPS_OFF: wps-face-mode center-title    leave those pieces off here
;;
;; Only names in `eh-fancy-components' are accepted; anything else is ignored.

(require 'seq)
(require 'subr-x)

(declare-function org-modern-mode "org-modern")
(declare-function org-pretty-table-mode "org-pretty-table")
(declare-function org-pretty-table-propertize-region "org-pretty-table")
(declare-function wps-face-mode "wps-face-mode")
(declare-function space-doc-mode "space-doc")

(defgroup eh-fancy nil "Fancy eirikur mode for Org files." :group 'org)

(defcustom eh-fancy-components '(org-modern org-pretty-table wps-face-mode center-title)
  "Pieces `eh-fancy-mode' turns on, in order.  Add `space-doc-mode' to use it."
  :type '(repeat (choice (const org-modern) (const org-pretty-table)
                         (const wps-face-mode) (const center-title)
                         (const space-doc-mode)))
  :group 'eh-fancy)

(defcustom eh-fancy-tag "WPS"
  "File tag that asks for `eh-fancy-mode'."
  :type 'string :group 'eh-fancy)

(defcustom eh-fancy-directories (list "~/org/days/")
  "Org files under these directories get `eh-fancy-mode' without a tag."
  :type '(repeat directory) :group 'eh-fancy)

(defvar-local eh-fancy--active nil
  "Components that are on in this buffer, so turning the mode off undoes them.")

;;; Reading the file (data only)

(defun eh-fancy--keyword-values (name)
  "All whitespace-separated words on the \"#+NAME:\" lines of this buffer."
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-min))
      (let ((case-fold-search t)
            (re (format "^#\\+%s:[ \t]*\\(.*\\)$" (regexp-quote name)))
            words)
        (while (re-search-forward re nil t)
          (setq words (append words (split-string (match-string 1) "[: \t]+" t))))
        words))))

(defun eh-fancy--wanted-p ()
  "Non-nil if this buffer asks for fancy mode: by tag or by directory."
  (or (seq-some (lambda (w) (string-equal-ignore-case w eh-fancy-tag))
                (eh-fancy--keyword-values "FILETAGS"))
      (and buffer-file-name
           (seq-some (lambda (d)
                       (let ((dir (expand-file-name d)))
                         (and (file-directory-p dir)
                              (file-in-directory-p buffer-file-name dir))))
                     eh-fancy-directories))))

(defun eh-fancy--off-list ()
  "Components this file turns off with #+WPS_OFF:, matched by name, never interned."
  (let ((names (eh-fancy--keyword-values "WPS_OFF")))
    (seq-filter (lambda (c) (member (symbol-name c) names)) eh-fancy-components)))

;;; The pieces.  Each takes ON: t to turn it on in this buffer, nil to undo.

(defun eh-fancy--org-modern (on)
  (if on
      (when (require 'org-modern nil t)
        ;; org-modern hides every star; org-pretty-table (not org-modern)
        ;; draws the tables.
        (setq-local org-modern-hide-stars t
                    org-modern-star nil
                    org-modern-table nil
                    ;; A round bullet; the default en dash looks like a tilde
                    ;; in Lucida Casual.
                    org-modern-list '((?+ . "•") (?- . "•") (?* . "•"))
                    ;; Hide "#+TITLE:" entirely; other keywords lose only "#+".
                    org-modern-keyword '(("title" . "") (t . t)))
        (org-modern-mode 1))
    (when (bound-and-true-p org-modern-mode) (org-modern-mode -1))))

(defun eh-fancy--org-pretty-table (on)
  (if on
      (when (require 'org-pretty-table nil t)
        (org-pretty-table-mode 1)
        ;; jit-lock runs the mode's function before font-lock, which then
        ;; wipes its glyphs; move it to the end of the list.
        (remove-hook 'jit-lock-functions #'org-pretty-table-propertize-region t)
        (add-hook 'jit-lock-functions #'org-pretty-table-propertize-region t t))
    (when (bound-and-true-p org-pretty-table-mode) (org-pretty-table-mode -1))))

(defun eh-fancy--wps-face-mode (on)
  (if on
      (when (require 'wps-face-mode nil t) (wps-face-mode 1))
    (when (bound-and-true-p wps-face-mode) (wps-face-mode -1))))

(defcustom eh-fancy-space-doc-skip '(view-mode)
  "space-doc modificators that fancy mode leaves out.
`view-mode' makes the buffer read-only, which is wrong for pages you type in."
  :type '(repeat symbol) :group 'eh-fancy)

(defun eh-fancy--space-doc-mode (on)
  (if on
      (when (require 'space-doc nil t)
        (let ((spacemacs-space-doc-modificators
               (seq-difference spacemacs-space-doc-modificators eh-fancy-space-doc-skip)))
          (space-doc-mode 1)))
    (when (bound-and-true-p space-doc-mode) (space-doc-mode -1))))

;; The title text starts at the left; a leading space whose :align-to is
;; `center' minus half the text's pixel width tracks the window size by itself.
(defun eh-fancy--title-overlays ()
  (seq-filter (lambda (o) (overlay-get o 'eh-fancy-title))
              (overlays-in (point-min) (point-max))))

(defun eh-fancy--center-title (&optional on)
  "Center the \"#+TITLE:\" text on its line, whatever the window width.
With ON nil (as a component being turned off) remove the centering."
  (mapc #'delete-overlay (eh-fancy--title-overlays))
  (when (or on (called-interactively-p 'any))
    (save-excursion
      (goto-char (point-min))
      (when (re-search-forward "^#\\+TITLE: *" nil t)
        (let* ((beg (match-end 0))
               (end (line-end-position))
               (win (get-buffer-window (current-buffer)))
               (px (and win (> end beg)
                        (car (window-text-pixel-size win beg end)))))
          (when px
            (let ((o (make-overlay beg beg)))
              (overlay-put o 'eh-fancy-title t)
              (overlay-put o 'before-string
                           (propertize " " 'display
                                       `(space :align-to (- center (,(/ px 2))))))))))))
  nil)

(defun eh-fancy--component-fn (c)
  (pcase c
    ('org-modern #'eh-fancy--org-modern)
    ('org-pretty-table #'eh-fancy--org-pretty-table)
    ('wps-face-mode #'eh-fancy--wps-face-mode)
    ('space-doc-mode #'eh-fancy--space-doc-mode)
    ('center-title #'eh-fancy--center-title)))

;;; The mode

(defun eh-fancy-refresh ()
  "Redo the pieces that depend on the buffer's text or window (the title)."
  (interactive)
  (when (memq 'center-title eh-fancy--active)
    (eh-fancy--center-title t)))

;;;###autoload
(define-minor-mode eh-fancy-mode
  "Org buffer with the whole fancy stack (see `eh-fancy-components')."
  :lighter " Fancy"
  (cond
   ((not (derived-mode-p 'org-mode))
    (setq eh-fancy-mode nil)
    (user-error "eh-fancy-mode is for Org buffers"))
   (eh-fancy-mode
    (let ((off (eh-fancy--off-list)))
      (dolist (c eh-fancy-components)
        (unless (memq c off)
          (condition-case err
              (progn (funcall (eh-fancy--component-fn c) t)
                     (push c eh-fancy--active))
            (error (message "eh-fancy %s: %S" c err)))))))
   (t
    (dolist (c eh-fancy--active)
      (condition-case err
          (funcall (eh-fancy--component-fn c) nil)
        (error (message "eh-fancy %s: %S" c err))))
    (setq eh-fancy--active nil))))

(defun eh-fancy-maybe ()
  "On `org-mode-hook': start `eh-fancy-mode' if this file asks for it."
  (when (and (derived-mode-p 'org-mode) (eh-fancy--wanted-p))
    (eh-fancy-mode 1)))

(add-hook 'org-mode-hook #'eh-fancy-maybe)

(provide 'eh-fancy)
;;; eh-fancy.el ends here
