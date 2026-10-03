;;; init.el --- -*- lexical-binding: t; -*-
;; Time-stamp: <2026-09-30 11:49:07 (eh)>


;; Sections (search for ";;;; " to jump between them):
;;    1. Startup basics      clock, Customize, package archives, use-package
;;    2. Load path
;;    3. Appearance          theme, title, mode line, cursor
;;    4. Editing defaults
;;    5. Files and backups   recentf, save-place, per-save backup, shebang chmod,
;;                            init.el syntax check
;;    6. Windows and mouse   one window at a time
;;    7. Programming         prog-mode and Python
;;    8. Writing             olivetti, fill/unfill, dictionary
;;    9. Small tools
;;   10. Keys                keys for built-in commands
;;   11. Startup             landing screen, server, load report
;;
;; Convention: a key for one of my own commands, or for a package feature, is
;; bound right next to it.  Keys for built-in commands live together in
;; section 10, so the whole keymap can be read (and conflicts spotted) in one
;; place.
;;
;; Ordering that matters:
;;   - package archives before `package-initialize', which comes before any
;;     use-package or theme;
;;   - the load path (section 2) before any `load-library';
;;   - everything `my-prog-mode-hook' calls is installed before the hook is
;;     added (installing a package runs `prog-mode-hook' in its source buffers);
;;   - the server functions before the load report at the very end.
;;
;; early-init.el owns: frame parameters, `package-enable-at-startup',
;; `load-prefer-newer', native-comp warnings and the eln cache location.

;;;; 1. Startup basics

(setq emacs-load-start-time (current-time)) ;; Should be first thing in file.

;; Customize is deliberately neutered: its file is a throwaway that is never
;; loaded, so nothing it saves (including package.el's package-selected-packages)
;; can come back later as a surprise.  Settings live in this file only.
(setq custom-file (make-temp-file "emacs-custom-" nil ".el"))

;; early-init.el sets `package-enable-at-startup' to nil, so packages in elpa/
;; are only on `load-path' / `custom-theme-load-path' after this call.  It must
;; come before anything that requires a package or loads a theme.
(setq package-archives
      '(("melpa"        . "https://melpa.org/packages/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")
        ("gnu"          . "https://elpa.gnu.org/packages/")
        ))

;; Turn on priorities of package sources in Emacs 25
(setq package-archive-priorities
      '(("melpa-stable" . 10)
        ("elpa" . 20)
        ("gnu" . 5)
        ))
(package-initialize)

(setq ;; `use-package'
 use-package-always-ensure t ;; Causes package archive lookups at startup.
 use-package-always-defer t
 ;; use-package-enable-imenu-support t
 use-package-minimum-reported-time 0
 use-package-verbose t)
(eval-when-compile
  (require 'use-package))
;; All keys are set with `bind-key' (what `use-package' :bind uses), always in
;; `kbd' syntax ("C-c d", "<home>", "s-f").  `M-x describe-personal-keybindings'
;; then lists every key set here and shows anything that overrides another.
(require 'bind-key)

(message "Package system up.")

;;;; 2. Load path

(dolist (p '("local" "eh" "themes"))
  (add-to-list 'load-path
               (expand-file-name
                (locate-user-emacs-file p))))

;;;; 3. Appearance
;; Frame parameters (font, size, colors) live in early-init.el
;; (`default-frame-alist'), not here.

(setq no-confirm-load-theme t)
(setq custom-safe-themes t)
(use-package waher-theme
  :demand t
  :config (load-theme 'waher :no-confirm))

(setq inhibit-splash-screen t)
(fset 'display-startup-echo-area-message 'ignore)

(setq frame-title-format
      (list
       "ξmacs:  "
       '((:eval (if (buffer-file-name)
                    (abbreviate-file-name (buffer-file-name))
                  "%b")))
       "  on  "
       (system-name)))

;; Mode line.  eh-mode-line installs spaceline and friends, so it must load
;; before `spaceline-config' is required.
(setq spaceline-all-the-icons-slim-render t)
(load-library "eh-mode-line")
(require 'spaceline-config)
;; (require 'EH-spaceline-all-the-icons-separators)
(spaceline-all-the-icons-theme)

;; Toggle the scroll bar, tool bar and menu bar.
(defvar trimmings-active)
(setq trimmings-active nil)
(defun trimmings ()
  "Display toolbar, menubar and scrollbar."
  (interactive)
  (if trimmings-active
      (setq trimmings-active -1)
    (setq trimmings-active t)
    )
  ;;  (message trimmings-active)
  (scroll-bar-mode trimmings-active)
  (tool-bar-mode trimmings-active)
  (menu-bar-mode trimmings-active)
  )
(bind-key "C-c t" #'trimmings)

;; Things needed but can't run every startup.
(defun eh/first-run ()
  (all-the-icons-install-fonts t)
  )

;; Cursor: color, shape, blink and beacon.
(load-library "eh-cursor")

;;;; 4. Editing defaults

;; Speak UTF-8 regardless of the locale Emacs is started under (Eiríkur).
;; With a UTF-8 locale Emacs already does this; these two lines make it so
;; under LANG=C, from a cron job, or over ssh with a bare environment.
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)

(defconst query-replace-highlight t)    ; Highlight during query
(defconst search-highlight t)           ; Hilight incremental search
(setq lazy-highlight-initial-delay 2)
(setq cursor-in-nonselected-windows t)
(setq scroll-step 1)                    ; Don't make big jumps
(defalias 'yes-or-no-p 'y-or-n-p )      ; Don't want to type y-e-s
(setq-default
 ;; we usually want a final newline...
 require-final-newline 't
 ;; require-final-newline nil
 ;; No tabs in my programs!
 ;; indent-tabs-mode nil
 ;; I don't like emacs destroying my window setup
 even-window-heights nil
 ;; Same here
 ;; resize-mini-windows t
 max-mini-window-height 10
 ;; No am/pm here
 display-time-24hr-format t
 ;; A tab is 8 spaces is 8 spaces is 8 spaces
 default-tab-width 4
 ;; case insensitivity for the masses!
 case-fold-search t
 read-file-name-completion-ignore-case t
 completion-ignore-case t
 ;; Looking at wrapped lines causes eye/brain-strain
 truncate-lines t
 what-cursor-show-names t
 )

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)

(delete-selection-mode t)

;;;; 5. Files and backups

;; time-stamps
(setq ;; when there's "Time-stamp: <>" in the first 10 lines of the file
  time-stamp-active t ; do enable time-stamps
  time-stamp-line-limit 10   ; check first 10 buffer lines for Time-stamp: <>
  time-stamp-format "%Y-%02m-%02d %02H:%02M:%02S (%u)") ; date format
(add-hook 'before-save-hook 'time-stamp)

;; Refuse to save init.el or early-init.el when it no longer reads as Lisp, so
;; a stray paren can't leave Emacs unable to start.  The check only reads the
;; forms (nothing is evaluated).  Auto-save still keeps the unsaved edits.
(defvar eh/verify-init-on-save t
  "Non-nil means saving init.el or early-init.el first checks that it reads.
To save a half-finished edit anyway: M-: (setq eh/verify-init-on-save nil)")

(defun eh/verify-init-before-save ()
  "Abort the save if this init file has unbalanced parens or bad syntax.
Leaves point on the problem; otherwise leaves point where it was.
Runs from `write-file-functions' because errors in `before-save-hook' are
demoted to messages and the save goes ahead.  Returns nil so the file is
then written normally."
  (when (and eh/verify-init-on-save
             buffer-file-name
             (member (file-truename buffer-file-name)
                     (mapcar (lambda (f) (file-truename (locate-user-emacs-file f)))
                             '("init.el" "early-init.el"))))
    (let ((start (point))
          problem)
      (save-restriction
        (widen)
        (push-mark start t)
        (condition-case err
            (progn
              (check-parens)            ; unbalanced: reports the spot
              (goto-char (point-min))
              (while (progn (forward-comment (point-max)) (not (eobp)))
                (read (current-buffer))))
          (error (setq problem err)))
        (if problem
            (user-error "%s NOT saved, line %d: %s"
                        (file-name-nondirectory buffer-file-name)
                        (line-number-at-pos)
                        (error-message-string problem))
          (goto-char start)))))
  nil)
;; Runs after `before-save-hook' (so after `time-stamp') and before the write.
(add-hook 'write-file-functions #'eh/verify-init-before-save)


(use-package recentf)
(recentf-mode t)
(save-place-mode)
(global-auto-revert-mode t)

;; Save everything when Emacs loses focus.
(add-function :after after-focus-change-function
              (lambda () (unless (frame-focus-state) (save-some-buffers t))))

;; Back up every file on save.  ~/scripts/emacs-push.sh keeps a timestamped
;; local copy in ~/.emacs.d/Emacs_Backups and pushes to the other machines.
(defun eh-backup-file ()
  "Execute a shell script to backup the just-saved file."
  (interactive)
  (message "%s" (shell-command-to-string (concat "~/scripts/emacs-push.sh "
						 buffer-file-name)))

)
(add-hook 'after-save-hook 'eh-backup-file)

;; Make sure to set files that begin with shebang executable.
;; shebang library didn't work, but this code from hlu does
(defun hlu-make-script-executable ()
  "If file starts with a shebang, make `buffer-file-name' executable"
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-min))
      (when (and (looking-at "^#!")
                 (not (file-executable-p buffer-file-name)))
        (set-file-modes buffer-file-name
                        (logior (file-modes buffer-file-name) #o100))
        ;; (message (concat "Made executable." buffer-file-name))))))
        (message (concat "Made executable."))))))
(add-hook 'after-save-hook 'hlu-make-script-executable)

;;;; 6. Windows and mouse
;; One window at a time, GUI-style.

(defun eh/solo-window (&rest _)
  "Make the selected window the only window in its frame."
  (delete-other-windows))

(defun eh/click-solo (event)
  "Like `mouse-set-point', then make the clicked window the only window.
Clicks in the minibuffer are left alone."
  (interactive "e")
  (mouse-set-point event)
  (unless (window-minibuffer-p (posn-window (event-start event)))
    (delete-other-windows)))
(bind-key "<mouse-1>" #'eh/click-solo)

;; Picking a file from the recentf list leaves just that file on screen.
;; The action is the click/RET path; the other is the dialog's digit keys
;; (and `recentf-open-most-recent-file' itself).
(with-eval-after-load 'recentf
  (dolist (fn '(recentf-open-files-action recentf-open-most-recent-file))
    (advice-add fn :after #'eh/solo-window)))

;; from "Life is too short for Bad Code" blog.
(defun stop-using-minibuffer ()
  "kill the minibuffer"
  (when (and (>= (recursion-depth) 1) (active-minibuffer-window))
    (abort-recursive-edit)))
(add-hook 'mouse-leave-buffer-hook 'stop-using-minibuffer)

(defun eh/toggle-visible ()
  "Pop up via sxhkd"
  (interactive)
;;  (sit-for 5)
  (raise-frame)
  (x-focus-frame nil)
  (message "toggle-visible")
  )

(setq global-text-scale-adjust-resizes-frames t) ; zoom keys are in section 10

;;;; 7. Programming

(use-package company)
(use-package fira-code-mode)
(use-package rainbow-delimiters)
(use-package rainbow-mode) ;; colorize color names and hex strings.
(autoload 'rainbow-mode "rainbow-mode")

(defun my-prog-mode-hook ()
  (fira-code-mode t)
  (setq tab-always-indent 'complete) ;; tries to indent, complete if indented already.
  (company-mode 1)
  ;; (rainbow-blocks-mode t)
  (rainbow-delimiters-mode t)
  (rainbow-mode t)
  ;; Show the current function name in the mode line
  (which-function-mode)
  )
(add-hook 'prog-mode-hook 'my-prog-mode-hook)
(bind-keys :map prog-mode-map
           ("C-c i" . indent-region)
           ("C-c c" . comment-line))
;; *scratch* already exists, so the hook above never ran for it.
(rainbow-delimiters-mode)

;;; Python
;; Put a breakpoint() line above the current one / remove all of them.
;; Bound to M-p and M-P in python-mode below.
(defun eh/pdb ()
  (interactive)
  (beginning-of-line)
  (open-line 1)
  (indent-for-tab-command)
  (insert "breakpoint()")
  (beginning-of-line)
  (indent-for-tab-command)
  (save-buffer)
  ;;                   )
  )

(defun eh/nopdb ()
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (flush-lines "breakpoint()")
    )
  (save-buffer)
  )

(defun eh-python-hook ()
  (interactive)
  (setq-default electric-indent-inhibit t)
  ;; (require 'realgud)
  (company-mode t)
  (setq indent-tabs-mode nil)
  (setq tab-width 4)
  (rainbow-delimiters-mode-enable)
  (add-to-list 'write-file-functions 'delete-trailing-whitespace)
  )
(add-hook 'python-mode-hook 'eh-python-hook)
(use-package python
  :ensure nil                           ; built in
  :bind (:map python-mode-map
              ;; ("C-c C-c" . eh/send-to-python)
              ("C-," . python-indent-shift-left)
              ("C-." . python-indent-shift-right)
              ("<kp-4>" . python-indent-shift-left)
              ("<kp-6>" . python-indent-shift-right)
              ("M-p" . eh/pdb)
              ("M-P" . eh/nopdb)
              ("M-n" . display-line-numbers-mode)))

;;;; 8. Writing

(use-package olivetti)
(defun eh/olivetti ()
  "Things I like with olivetti-mode."
  (interactive)
  (require 'olivetti)
  (fringe-mode-initialize)
  (delete-other-windows)
  (olivetti-mode)
  (toggle-frame-fullscreen))
(bind-key "C-c d" #'eh/olivetti)

(defun endless/fill-or-unfill ()
  "Like `fill-paragraph', but unfill if used twice."
  (interactive)
  (let ((fill-column
         (if (eq last-command 'endless/fill-or-unfill)
             (progn (setq this-command nil)
                    (point-max))
           fill-column)))
    (call-interactively #'fill-paragraph)))
(bind-key [remap fill-paragraph] #'endless/fill-or-unfill)

(setopt dictionary-search-interface   'help
        dictionary-default-strategy  "prefix"
        dictionary-default-dictionary "gcide"
        dictionary-server             "dict.org")
(bind-key "M-#" #'dictionary-search)
(dictionary-tooltip-mode t)

;;;; 9. Small tools

(defun eh/elisp-eval ()
  (interactive)
  (if (region-active-p)
      (eval-region (region-beginning) (region-end))
    (eval-buffer)
    )
  )
(bind-key "C-c e" #'eh/elisp-eval)

(defun eh/what-face (pos)
  "Show the name of face under point."
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))
(bind-key "C-c w" #'eh/what-face)

;; Follow Claude Code's edits in a side window; C-c v flips diff <-> file.
;; A hook script (outside this repo) feeds it through emacsclient.
(load-library "eh-claude-follow")
(bind-key "C-c v" #'eh/claude-follow-toggle)

(use-package show-font
  :ensure t
  :bind
  (("C-c C-f" . show-font-select-preview)
   ("C-c f" . show-font-tabulated)))

(use-package fill-column-indicator
  :init
  (setq fci-rule-width 1)
  (setq fci-rule-color "darkgrey")
  :bind ("C-c F" . fci-mode))

(use-package color-moccur               ; multi-buffer occur (grep)
  :bind ("C-c m" . moccur))

;; A real terminal in Emacs (M-x vterm), from Debian's elpa-vterm and
;; emacs-libvterm packages (the module is prebuilt).  29.3 finds them by
;; itself; the 32.0.50 build in /usr/local doesn't look under /usr/share.
;; Building the MELPA vterm from source fails here: /usr/bin/libtool is a stray
;; symlink to libtoolize, which is not libtool, and libvterm's build needs
;; the real one (package libtool-bin).
;; So do NOT declare this with `use-package vterm :ensure t': the MELPA copy
;; would install into the shared elpa/, outrank Debian's on BOTH binaries, and
;; (having no module) break vterm on 29.3 as well.
(unless (locate-library "vterm")
  (let ((dir (car (last (file-expand-wildcards
                         "/usr/share/emacs/site-lisp/elpa/vterm-*")))))
    (when dir (add-to-list 'load-path dir))))
(autoload 'vterm "vterm" "Terminal emulator." t)

(use-package sxhkdrc-mode)
(use-package vundo)

;;;; 10. Keys
;; Keys for built-in commands.  Keys for my own commands are next to the
;; commands (sections 6, 8 and 9).

;; Mar. 21 2026
(unbind-key "C-z")
(unbind-key "M-z")
;; Super-i bound to insert i-accute
(bind-key "s-i" (lambda () (interactive) (insert ?\í)))

;; Navigation
(bind-key "<home>" #'beginning-of-buffer)
(bind-key "<end>" #'end-of-buffer)
(bind-key "<select>" #'end-of-buffer)
(bind-key "C-<tab>" #'mode-line-other-buffer) ;; Finally 6Nov24
;; Hideshow.  In the old string syntax "\C-T" was the very same key as "\C-t",
;; so hide-all silently replaced toggle-hiding.  Now they are two keys.
(bind-key "C-t" #'hs-toggle-hiding)
(bind-key "C-S-t" #'hs-hide-all)

;; Open my init / profile
(bind-key "<insert>" (lambda () (interactive)
                       (find-file "~/.emacs.d/init.el")
                       (delete-other-windows)))
(bind-key "S-<insert>" (lambda () (interactive)
                         (find-file "~/.profile")
                         (delete-other-windows)))

;; Keypad
(bind-key "<kp-end>" #'delete-other-windows)
(bind-key "<kp-enter>" #'execute-extended-command)
(bind-key "<kp-insert>" #'delete-window)
(bind-key "<kp-1>" #'delete-other-windows)
(bind-key "<kp-0>" #'delete-window)

;; Zoom in and out.
(bind-key "C-=" #'text-scale-increase)
(bind-key "C--" #'text-scale-decrease)

;; C-c prefix
(bind-key "C-c o" #'occur)
(bind-key "C-c b" #'list-bookmarks)
;; (bind-key "C-c s" #'sudo-edit)
(bind-key "C-c C-k" #'kill-emacs)
(bind-key "C-c r" #'recentf-open-files)
(bind-key "C-c R" #'recentf-open-most-recent-file)
(bind-key "C-c i" #'indent-region)
(bind-key "s-f" #'make-frame)

;;;; 11. Startup
;; Landing screen, Emacs server, then the load report.

;;; Landing screen for Emacs/emacsclient with no file argument.
;; Goal: when entering Emacs without asking for a specific file, show the most
;; recent edited file in the main window, with the `recentf' chooser below it.
;; This deliberately does not run when Emacs/emacsclient is visiting a file.
(require 'seq)
(defvar eh/startup-had-file-args
  (seq-some (lambda (arg)
              (and (stringp arg)
                   (not (string-prefix-p "-" arg))))
            command-line-args-left)
  "Non-nil when this Emacs startup was given a file-like command-line arg.")

(defcustom eh/landing-recentf-window-height 14
  "Height of the lower recentf chooser window in `eh/landing-screen'."
  :type 'integer
  :group 'convenience)

(defun eh/recentf-existing-file-list ()
  "Return `recentf-list' entries that are readable, non-directory files."
  (require 'recentf)
  (unless recentf-mode
    (recentf-mode 1))
  (seq-filter (lambda (file)
                (and (stringp file)
                     (file-readable-p file)
                     (not (file-directory-p file))))
              recentf-list))

(defun eh/recentf-most-recent-file ()
  "Return the most recent readable non-directory file from `recentf-list'."
  (car (eh/recentf-existing-file-list)))

(defun eh/landing-screen (&optional force)
  "Show the most recent file above a `recentf' chooser.

With prefix argument FORCE, show the landing screen even when the current
buffer is already visiting a file.  Without FORCE, do nothing in file-visiting
buffers, so file arguments to Emacs or emacsclient are not hijacked."
  (interactive "P")
  (require 'recentf)
  (unless recentf-mode
    (recentf-mode 1))
  (when (or force (not (buffer-file-name (window-buffer (selected-window)))))
    (let ((file (eh/recentf-most-recent-file))
          (recentf-height (max 4 eh/landing-recentf-window-height)))
      (delete-other-windows)
      (when file
        (find-file file))
      (let ((main-window (selected-window)))
        (when (and recentf-list
                   (> (window-total-height main-window)
                      (+ recentf-height window-min-height 2)))
          (select-window (split-window main-window (- recentf-height) 'below))
          (condition-case err
              (recentf-open-files)
            (error
             (switch-to-buffer (get-buffer-create "*Messages*"))
             (message "Could not open recentf chooser: %S" err)))
          (select-window main-window))))))

(defun eh/landing-screen-maybe ()
  "Show `eh/landing-screen' on startup if no file was requested."
  (unless eh/startup-had-file-args
    (eh/landing-screen)))

(defun eh/landing-screen-maybe-for-client-frame ()
  "Show `eh/landing-screen' for an emacsclient frame with no file buffer.
Run after a zero-second timer so file-visiting clients get their file first."
  (let ((frame (selected-frame)))
    (run-at-time
     0 nil
     (lambda (frame)
       (when (frame-live-p frame)
         (with-selected-frame frame
           (eh/landing-screen))))
     frame)))

(add-hook 'emacs-startup-hook #'eh/landing-screen-maybe)

(with-eval-after-load 'server
  (add-hook 'server-after-make-frame-hook
            #'eh/landing-screen-maybe-for-client-frame))

;;; Emacs server for emacsclient.
;; Start a server in normal interactive Emacs so `emacsclient' can reuse this
;; session.  Do not do this in batch jobs/tests.  The status message at the end
;; uses `eh/server-id-string' rather than merely checking whether
;; `server-socket-dir' is bound; that variable can be misleading unless the
;; server library has been loaded and a server was actually started.
(defun eh/current-emacs-server-running-p ()
  "Return non-nil if this Emacs process has a live server process."
  (and (boundp 'server-process)
       (processp server-process)
       (process-live-p server-process)))

(defun eh/server-start-maybe ()
  "Start the Emacs server unless one is already running."
  (require 'server)
  (condition-case err
      (cond
       ((eh/current-emacs-server-running-p)
        t)
       ((server-running-p)
        ;; Another Emacs already owns the default server socket/name.
        ;; Leave it alone rather than stealing or deleting sockets.
        (message "Emacs server already running elsewhere: %s" server-name)
        nil)
       (t
        (server-start)
        (eh/current-emacs-server-running-p)))
    (error
     (message "Could not start Emacs server: %s" (error-message-string err))
     nil)))

(defun eh/server-id-string ()
  "Return a human-readable description of the current Emacs server state."
  (cond
   ((not (featurep 'server))
    "No server.")
   ((eh/current-emacs-server-running-p)
    (format "%s pid %s" server-name (emacs-pid)))
   ((server-running-p)
    (format "%s already running elsewhere" server-name))
   (t
    "No server.")))

(unless noninteractive
  (eh/server-start-maybe))

;;; Emacs initialization was successful. (We got this far.)
;; (setq emacs-name "ξmacs") ;;(propertize "ξmacs" 'face  '(:foreground "blue")))
(setq emacs-name (propertize "ξmacs" 'face  '(:foreground "deepskyblue")))
(setq version (format "%s %S.%S" emacs-name emacs-major-version emacs-minor-version))
;; (setq init-from  (propertize user-init-file 'face  '(:foreground "yellow")))
(setq init-from  (propertize (file-name-nondirectory (or user-init-file "init.el")) 'face  '(:foreground "yellow")))

(setq time-message (format "%s loaded from %s in %0.2fs" version init-from
                           (float-time (time-since emacs-load-start-time))))

(setq server-id
      (let ((id (eh/server-id-string)))
        (propertize id 'face `(:foreground ,(if (string-prefix-p "No server" id)
                                                "red"
                                              "blue")))))

(message "%s   GCs: %S in %0.2fs  %s"
	 time-message gcs-done gc-elapsed server-id)

;; Hack. Emacs doesn't get input focus automatically.
(select-frame-set-input-focus (selected-frame))

;; init.el ends

;; One-page plan for today (~/org/days/YYYY-MM-DD.org); carries over yesterday.
(load-library "eh-today")
(bind-key "C-c T" #'eh-today)
