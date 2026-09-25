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
