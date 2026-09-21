;;; init.el --- -*- lexical-binding: t; -*-
;; early-init.el sets `package-enable-at-startup' to nil, so packages in elpa/
;; are only on `load-path' / `custom-theme-load-path' after this call.  It must
;; come before anything that requires a package or loads a theme.
(package-initialize)

(setq no-confirm-load-theme t)
(load-theme 'waher :no-confirm)

(setq inhibit-splash-screen t)
(fset 'display-startup-echo-area-message 'ignore)

;; Xah's no-keymap keymap. Try local-set key.
(global-set-key (kbd "`") nil)
(global-set-key (kbd "` a") 'cmd1)
(global-set-key (kbd "` b") 'cmd2)
(global-set-key (kbd "` c") 'cmd3)









;; Powerline issues.
(setq native-comp-async-report-warnings-errors 'silent)



;; (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(setq emacs-load-start-time (current-time)) ;; Should be first thing in file.

(setq load-prefer-newer t)
(setq custom-safe-themes t)
(setq no-confirm-load-theme t)
(use-package show-font
  :ensure t
  :bind
  (("C-c C-f" . show-font-select-preview)
   ("C-c f" . show-font-tabulated)))
;;; Frames: parameters live in early-init.el (`default-frame-alist').

 ;;; Offload the custom-set-variables to a separate file
 ;;; This keeps your init.el neater and you have the option
 ;;; to gitignore your custom.el if you see fit.
 (setq custom-file "~/.emacs.d/custom.el")
 (unless (file-exists-p custom-file)
   (write-region "" nil custom-file))
 ;;; Load custom file. Don't hide errors. Hide success message
(load custom-file nil t)

(defun eh/elisp-eval ()
  (interactive)
  (if (region-active-p)
      (eval-region (region-beginning) (region-end))
    (eval-buffer)
    )
  )
(global-set-key (kbd "C-c e") 'eh/elisp-eval)

(defun eh/what-face (pos)
  "Show the name of face under point."
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))
(global-set-key (kbd "C-c w") 'eh/what-face)


(use-package fill-column-indicator
  :init
  (setq fci-rule-width 1)
  (setq fci-rule-color "darkgrey")
  (global-set-key "\C-cF" 'fci-mode)
  )

;;; Keys
;; Mar. 21 2026
(global-unset-key (kbd "C-z"))
(global-unset-key (kbd "M-z"))
;; Super-i bound to insert i-accute
(global-set-key (kbd "s-i") (lambda () (interactive) (insert ?\í)))

;; Top-level key bindings
(global-set-key [home] 'beginning-of-buffer)
(global-set-key [end] 'end-of-buffer)
(global-set-key [select] 'end-of-buffer)
(global-set-key [insert] (lambda () (interactive)
			   (find-file "~/.emacs.d/init.el")
			   (delete-other-windows)))
(global-set-key [S-insert] (lambda () (interactive)
			   (find-file "~/.profile")
			   (delete-other-windows)))
(global-set-key "\C-cd" 'eh/olivetti)

(global-set-key [kp-end] 'delete-other-windows)
(global-set-key [kp-enter] 'execute-extended-command)
(global-set-key [kp-insert] 'delete-window)

(global-set-key [kp-7] 'kp-7-target)




;; (global-set-key (kbdB "C-c b") 'list-bookmarks)
(global-set-key (kbd "C-c t") 'trimmings)
(global-set-key (kbd "C-c o") 'occur)
(global-set-key (kbd "C-c b") 'list-bookmarks)
;; (global-set-key "\C-cs" 'sudo-edit)
(global-set-key "\C-c\C-k" 'kill-emacs)
(global-set-key "\C-co" 'occur)
(global-set-key (kbd "C-c m") 'moccur)
(global-set-key "\C-t" 'hs-toggle-hiding)
(global-set-key "\C-T" 'hs-hide-all)
(global-set-key (kbd "C-c r") 'recentf-open-files)
(global-set-key (kbd "C-c R") 'recentf-open-most-recent-file)
(global-set-key (kbd "<kp-1>") 'delete-other-windows)
(global-set-key (kbd "<kp-0>") 'delete-window)
;; Zoom in and out.
(global-set-key (kbd "C-=")      'text-scale-increase)
(global-set-key (kbd "C--")      'text-scale-decrease)
(global-set-key "\C-ci" 'indent-region)
(global-set-key [C-tab] 'mode-line-other-buffer) ;; Finally 6Nov24
(global-set-key [(super f)] 'make-frame)
(global-set-key (kbd "C-c e") 'eval-buffer) ;;'eh/elisp-eval)

;;; Paths
  (dolist (p '("local" "eh" "themes"))
    (add-to-list 'load-path
                 (expand-file-name
                  (locate-user-emacs-file p))))

(setq spaceline-all-the-icons-slim-render t)
(require 'spaceline-config)
(load-library "eh-mode-line")
;; (require 'EH-spaceline-all-the-icons-separators)
(spaceline-all-the-icons-theme)

(defun eh/toggle-visible ()
  "Pop up via sxhkd"
  (interactive)
;;  (sit-for 5)
  (raise-frame)
  (x-focus-frame nil)
  (message "toggle-visible")
  )



;;; Packages
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

(setq ;; `use-package'
 use-package-always-ensure t ;; Causes package archive lookups at startup.
 use-package-always-defer t
 ;; use-package-enable-imenu-support t
 use-package-minimum-reported-time 0
 use-package-verbose t)
(eval-when-compile
  (require 'use-package))

(message "Package system up.")

;;; Things needed but can't run every startup.
(defun eh/first-run ()
  (all-the-icons-install-fonts t)
  )

;; Miscellaneous Standard Emacs settings.
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
(put 'dired-find-alternate-file 'disabled nil)

(add-function :after after-focus-change-function (lambda () (unless (frame-focus-state) (save-some-buffers t))))


(defun my-prog-mode-hook ()
  (fira-code-mode t)
  (setq tab-always-indent 'complete) ;; tries to indent, complete if indented already.
  (company-mode 1)
  ;; (rainbow-blocks-mode t)
  (rainbow-delimiters-mode t)
  (rainbow-mode t)
  ;; Show the current function name in the mode line
  (which-function-mode)
  (local-set-key "\C-ci" 'indent-region)
  (local-set-key "\C-cc" 'comment-line)
  )
(add-hook 'prog-mode-hook 'my-prog-mode-hook)

;; (use-package uv
;;   :straight (uv :type git :host github :repo "johannes-mueller/uv.el"))
;; (use-package uv)
;; (use-package tomlparse)

;; (use-package uv-mode
;;   :hook (python-mode . uv-mode-auto-activate-hook))

;;; Python
(defun eh-python-hook ()
  (interactive)
  (setq-default electric-indent-inhibit t)
  ;; (require 'realgud)
  (company-mode t)
  (setq indent-tabs-mode nil)
  (setq tab-width 4)
  (rainbow-delimiters-mode-enable)
  ;; (local-set-key (kbd "C-c C-c") 'eh/send-to-python)
  (local-set-key (kbd "C-,") '
		 python-indent-shift-left)
  (local-set-key (kbd "C-.") 'python-indent-shift-right)
  (local-set-key (kbd "<kp-4>") 'python-indent-shift-left)
  (local-set-key (kbd "<kp-6>") 'python-indent-shift-right)

  (local-set-key (kbd "M-p") 'eh/pdb)
  (local-set-key (kbd "M-P") 'eh/nopdb)
  (local-set-key (kbd "M-n") 'display-line-numbers-mode)
  (add-to-list 'write-file-functions 'delete-trailing-whitespace)
  )

(add-hook 'python-mode-hook 'eh-python-hook)



(use-package rainbow-delimiters)
;; (autoload 'rainbow-delimiters "rainbow-delimiters")

(use-package rainbow-mode) ;; colorize color names and hex strings.
(autoload 'rainbow-mode "rainbow-mode")




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
        ;; (message (concat "Made " buffer-file-name " executable"))))))
        (message (concat "Made executable."))))))
(add-hook 'after-save-hook 'hlu-make-script-executable)

;; from "Life is too short for Bad Code" blog.
(defun stop-using-minibuffer ()
  "kill the minibuffer"
  (when (and (>= (recursion-depth) 1) (active-minibuffer-window))
    (abort-recursive-edit)))

(add-hook 'mouse-leave-buffer-hook 'stop-using-minibuffer)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Needs re-org. Not part of minimal config.
;;;;; Needs Lucida Casual (load-library "eh-mode-line")





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;; Schedule eh-mode-line for after init done.
;; (load-library "eh-mode-line")
;; (spaceline-all-the-icons-theme)



;; (Add-hook 'emacs-startup-hook
;; 	  (lambda () (bury-buffer " *Warnings* ")))

;; ;; ;; ;; ;; ;; Trials f   rom old moby init.el:
;;
(add-function :after after-focus-change-function (lambda () (unless (frame-focus-state) (save-some-buffers t))))

(defun endless/fill-or-unfill ()
  "Like `fill-paragraph', but unfill if used twice."
  (interactive)
  (let ((fill-column
         (if (eq last-command 'endless/fill-or-unfill)
             (progn (setq this-command nil)
                    (point-max))
           fill-column)))
    (call-interactively #'fill-paragraph)))

(global-set-key [remap fill-paragraph]
                #'endless/fill-or-unfill)

(defun eh/elisp-eval ()
  (interactive)
  (if (region-active-p)
      (eval-region (region-beginning) (region-end))
    (eval-buffer)
    )
  )
(global-set-key (kbd "C-c e") 'eh/elisp-eval)

;; End trials from old moby.



(use-package sxhkdrc-mode)

(use-package rainbow-delimiters)
(rainbow-delimiters-mode)

(load-library "eh-cursor")

(use-package recentf)
(recentf-mode t)

(setq global-text-scale-adjust-resizes-frames t)

(use-package vundo)

;; Load init-heavy.el

;; (add-hook 'emacs-startup-hook
;; (lambda () (interactive)
;;   (message "Waiting in lambda.")
;;   (sit-for 5)
;;   (select-frame-set-input-focus (selected-frame))
;; ))
;; (add-hook 'emacs-startup-hook 'raise-frame)

(save-place-mode)
;;;;;;;;;;;; Emacs initialization was successful. (We got this far.)
;; (setq emacs-name "ξmacs") ;;(propertize "ξmacs" 'face  '(:foreground "blue")))
(setq emacs-name (propertize "ξmacs" 'face  '(:foreground "deepskyblue")))
(setq version (format "%s %S.%S" emacs-name emacs-major-version emacs-minor-version))
;; (setq init-from  (propertize user-init-file 'face  '(:foreground "yellow")))
    (setq init-from  (propertize (file-name-nondirectory (or user-init-file "init.el")) 'face  '(:foreground "yellow")))

(setq time-message (format "%s loaded from %s in %0.2fs" version init-from
                           (float-time (time-since emacs-load-start-time))))



(if (boundp 'server-socket-dir)
    (setq server-id (propertize "Server" 'face '(:foreground "blue")))
  (setq server-id  (propertize "No server." 'face  '(:foreground "red"))))



(message "%s   GCs: %S in %0.2fs  %s"
	 time-message gcs-done gc-elapsed server-id)

;; Hack. Emacs doesn't get input focus automatically.
(select-frame-set-input-focus (selected-frame))

;; init.el ends
