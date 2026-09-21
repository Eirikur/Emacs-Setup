;;; early-init.el --- early bird  -*- no-byte-compile: t; lexical-binding: t; -*-

(when (boundp 'native-comp-eln-load-path)
  (startup-redirect-eln-cache "var/eln-cache"))
(setq max-specpdl-size 13000)
(setq warning-suppress-log-types '((files missing-lexbind-cookie)))
(setq native-comp-async-report-warnings-errors 'silent)

(setq package-enable-at-startup nil)
(setq load-prefer-newer t)

(defcustom rgr/elisp-dir (expand-file-name "etc/elisp" user-emacs-directory)
  "Where user elisp files should be stored."
  :type 'directory
  :group 'rgr)

(defun rgr/user-elisp-file (f)
  "Return the full path to a user Emacs Lisp file F."
  (expand-file-name f rgr/elisp-dir))

;; Ensure the directory exists before adding it to load-path
(make-directory rgr/elisp-dir t)

;; Add the directory to the load-path, preferring to the front and avoiding duplicates.
(add-to-list 'load-path rgr/elisp-dir)

;;; Frame parameters -- the ONE place they are set.  The first GUI frame is
;;; created before init.el runs, so anything set later only patches it up after
;;; the fact (resize jump, color flash).  Don't set `default-frame-alist' in
;;; init.el: that would replace this list for every later frame.
;;; background-color matches waher's `default' face; change it with the theme.
;;; foreground-color is left out on purpose: a frame parameter overrides the
;;; theme's text color, so the theme is left to set it.
(setq default-frame-alist
      '((font . "Fira Code 32")           ; use show-font to get the name
        (width . 85)
        (height . 50)
        (background-color . "#000000")
        (vertical-scroll-bars . nil)
        (horizontal-scroll-bars . nil)
        (tool-bar-lines . 0)
        (left-fringe . 5)
        (right-fringe . 5)
        (right-divider-width . 3)))

