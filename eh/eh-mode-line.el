;; (set-face-attribute 'mode-line nil :font "LucidaCasual 24" :background 'unspecified  :height 180)  -*- lexical-binding: t; -*-

;;-pyrs-FontAwesome-regular-normal-normal-*-*-*-*-*-*-0-iso10646-1
;;(set-face-attribute 'mode-line nil :font "FontAwesome" :background 'unspecified :height 235)


(use-package all-the-icons
  :ensure t
  :demand t
  )

(use-package spaceline
  :ensure t
  :demand t
  )

(use-package spaceline-all-the-icons
  ;; :load-path "etc/elisp-packages/spaceline-all-the-icons"
  :demand t
  :after spaceline
  :config
  (setq spaceline-all-the-icons-icon-set-bookmark 'heart
        spaceline-all-the-icons-icon-set-modified 'chain
        spaceline-all-the-icons-icon-set-dedicated 'pin
        spaceline-all-the-icons-separator-type 'wave
        spaceline-all-the-icons-icon-set-flycheck-slim 'dotsphil
        spaceline-all-the-icons-flycheck-alternate 'solid
        spaceline-all-the-icons-icon-set-window-numbering 'circle
        spaceline-all-the-icons-highlight-file-name t
	;; spaceline-all-the-icons-file-name-highlight t
        spaceline-all-the-icons-hide-long-buffer-path t)
  ;; spaceline-all-the-icons-separator-type 'none)
  (spaceline-toggle-all-the-icons-bookmark-off)
  ;; (spaceline-toggle-all-the-icons-fullscreen-off)
  ;; (spaceline-toggle-all-the-icons-buffer-position-on)
  (spaceline-toggle-all-the-icons-buffer-position-off) ;; ?Fix for modeline height.
  (spaceline-toggle-all-the-icons-hud-off)
  (spaceline-toggle-all-the-icons-package-updates-on)
  ;; IMPORTANT: Do not re-enable the spaceline-all-the-icons Paradox
  ;; integration during cleanup/refactoring.
  ;;
  ;; `spaceline-all-the-icons--setup-paradox' installs anonymous hooks/advice
  ;; into Paradox's package menu mode line.  Paradox itself globally overrides
  ;; several package.el functions, so failures there can appear later as broken
  ;; `package-list-packages' behavior.  We debugged a package-menu failure in
  ;; Sep 2026; the final cause was a Paradox/package-vc status incompatibility,
  ;; but this mode-line integration was a plausible and fragile contributor.
  ;; Leave it disabled unless it has been deliberately re-tested with both:
  ;;   M-x paradox-list-packages
  ;;   M-x package-list-packages
  ;; (spaceline-all-the-icons--setup-paradox)
;;  (spaceline-all-the-icons-theme)
  )

;;; Fonts.  The mode line is set in Lucida Casual; only the file name uses
;;; the terminal font.  The frame's default font is left alone.  Only the
;;; family is set on the faces, so the spaceline scaling
;;; (`spaceline-all-the-icons--height') keeps working.
;;; Lucida Casual runs small next to Fira Code, so it is enlarged with
;;; `face-font-rescale-alist' rather than a face :height: that rescales only
;;; this font's glyphs, not the wave separators, which are icon-font glyphs
;;; sized separately.  The separators still fill the bar at any scale; the
;;; scale only sets the bar height (70 px at 1.0, 77 px at 1.2, 88 px at 1.35).
(add-to-list 'face-font-rescale-alist '("Lucida Casual" . 1.2))

(defface eh-mode-line-file-name
  '((t :family "DaddyTimeMono Nerd Font"))
  "Face for the file name in the mode line."
  :group 'spaceline-all-the-icons)

(defun eh-mode-line-set-fonts (&rest _)
  "Give the mode line its family.  Re-run after a theme is enabled."
  (dolist (face '(mode-line mode-line-inactive))
    (set-face-attribute face nil :family "Lucida Casual")))

(eh-mode-line-set-fonts)
(add-hook 'enable-theme-functions #'eh-mode-line-set-fonts)

;; Same as the stock segment in spaceline-all-the-icons-segments.el, except
;; the file name gets `eh-mode-line-file-name'.  (The stock code ends its face
;; list with a bare :inherit, which cannot carry a font.)  Spaceline inlines
;; segment code when the mode line is compiled, so this must be defined before
;; `spaceline-all-the-icons-theme' runs (init.el does that).
(spaceline-define-segment all-the-icons-buffer-id
  "An `all-the-icons' segment to display current buffer id"
  (let* ((height (if spaceline-all-the-icons-slim-render 1.0 0.8))
         (raise  (if spaceline-all-the-icons-slim-render 0.1 0.2))

         (help-echo (format "Major-mode: `%s'" major-mode))

         (file-face `(:height ,(spaceline-all-the-icons--height height)))
         (show-path? (and active
                          spaceline-all-the-icons-buffer-path-p
                          (spaceline-all-the-icons--buffer-path)
                          (not spaceline-all-the-icons-slim-render)))

         (have-projectile? (and (fboundp 'projectile-project-p) (projectile-project-p)))
         (show-projectile? (and spaceline-all-the-icons-projectile-p have-projectile?))

         (buffer-id (if (and (buffer-file-name)
                             (or show-path? show-projectile?))
                        (file-name-nondirectory (buffer-file-name))
                      (format-mode-line "%b")))

         (mouse-f (if have-projectile? 'projectile-find-file 'find-file)))

    (when (and spaceline-all-the-icons-highlight-file-name show-path?)
      (setq file-face (append `(:background ,(spaceline-all-the-icons--face-background default-face)
                                :foreground ,(or spaceline-all-the-icons-file-name-highlight
                                                 (spaceline-all-the-icons--face-background highlight-face)))
                              file-face)))
    (setq file-face (append file-face '(:inherit eh-mode-line-file-name)))

    (propertize buffer-id
                'face file-face
                'display `(raise ,raise)
                'help-echo help-echo
                'mouse-face (spaceline-all-the-icons--highlight)
                'local-map (make-mode-line-mouse-map 'mouse-1 mouse-f)))
  :tight t)

(if (fboundp 'spaceline-all-the-icons-theme)
    (message "Spaceline is good.")
  (message "Spaceline had a problem!"))

;;0ct 9, 2024. Brought back from old version:
(line-number-mode t)       ;; show line numbers
(column-number-mode t)     ;; show column numbers
;; (size-indication-mode t)   ;; show file size (emacs 22+)

;; (autoload 'sml-modeline-mode "sml-modeline")
;; (sml-modeline-mode 1)      ;; show buffer pos in the mode line


(defun silently (fn)
  (interactive)
  (with-no-warnings 'fn))



;; (add-hook 'emacs-startup-hook 'spaceline-all-the-icons-theme)

;; (add-hook 'emacs-startup-hook 'silently(spaceline-all-the-icons-theme))
;; (silently (spaceline-all-the-icons-theme))

(provide 'eh-mode-line)
(message "End of eh-mode-line")
