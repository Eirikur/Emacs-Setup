;; (set-face-attribute 'mode-line nil :font "LucidaCasual 24" :background 'unspecified  :height 180)  -*- lexical-binding: t; -*-
;;; CHANGING A MODE LINE FONT -- read this first.
;;
;; The mode line is spaceline-all-the-icons: text, icons and the orange/grey
;; wave dividers ("separators") are separate glyphs from three fonts, and the
;; dividers' size is fixed by spaceline, not by the text font.  Change a font
;; and the dividers no longer fit unless you re-fit them.  Three knobs below:
;;
;;  1. Family:  `eh-mode-line-set-fonts' (Lucida Casual on mode-line and
;;     mode-line-inactive).  File-name font: the :family string in the
;;     `all-the-icons-buffer-id' segment (DaddyTimeMono Nerd Font).
;;  2. Size:  the `face-font-rescale-alist' entry.  Its key is the font name,
;;     so change it when you change the family.  Use this, not a face :height:
;;     :height would also scale the dividers.  Icon sizes are separate:
;;     `eh-mode-line-modified-icon-scale' (the modified/lock icon).
;;  3. Dividers:  `eh-mode-line-separator-scale'.  RULE: the divider glyph must
;;     be at least as tall as the text line.  If not, the bar is a bit taller
;;     than the divider and every orange end cap stops short of the top and
;;     bottom edge (the curve does not span the bar).  Symptom to look for:
;;     the cap after the first block is not one smooth curve top to bottom.
;;     Numbers here: divider is 70 px at scale 1.0, and the Lucida line at
;;     rescale 1.2 is 78 px, so scale 1.1 (79 px) fits.  Try scale = (text
;;     line px / 70) rounded up; too big only makes the whole bar taller.
;;
;; Gotchas:
;;  - RESTART Emacs after any of this.  Spaceline compiles the mode line, and
;;    reloading this file into a running Emacs leaves the old one in place.
;;  - The file-name face must be an inner list, `((:height H :family F))'.
;;    Powerline appends the segment's face to whatever list we give it.  A
;;    face symbol, or a bare :inherit at the end, replaces the segment's
;;    background (dark patch behind the name) or overrides :family.
;;  - Heights alone can look right in a pixel measurement and still be wrong:
;;    check by eye at 3x zoom.  When testing, do not visit this file in a test
;;    Emacs (a stray keystroke there once ate the hyphen in `use-package').

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
;; The wave separators must be at least as tall as the text line, or the end
;; caps stop short of the top and bottom of the bar.  Their size is a fixed
;; 1.6 in spaceline; that matched Fira Code, but the enlarged Lucida line is
;; taller (78 px), so scale the separators (and only them) by this much.
;; If the Lucida scale above goes up, raise this too.  Check by eye: the
;; orange end cap should be one smooth curve from top to bottom.
(defvar eh-mode-line-separator-scale 1.1
  "Extra scale for the wave separators, on top of spaceline's 1.6.")

(defun eh-mode-line--scale-separators (orig &optional height)
  "Around advice for `spaceline-all-the-icons--height': enlarge separators."
  (let ((v (funcall orig height)))
    (if (eql height 1.6) (* v eh-mode-line-separator-scale) v)))
(advice-add 'spaceline-all-the-icons--height :around #'eh-mode-line--scale-separators)

(defun eh-mode-line-set-fonts (&rest _)
  "Give the mode line its family.  Re-run after a theme is enabled."
  (dolist (face '(mode-line mode-line-inactive))
    (set-face-attribute face nil :family "Lucida Casual")))

(eh-mode-line-set-fonts)
(add-hook 'enable-theme-functions #'eh-mode-line-set-fonts)

;; Same as the stock segment in spaceline-all-the-icons-segments.el, except
;; the file name gets the terminal font.  The face is a one-element list
;; holding the attributes, because powerline appends the segment's own face to
;; it: `((:height H :family F) powerline-active1)' keeps our font (first wins)
;; and still gets the segment's background.  The stock code ends its plist with
;; a bare :inherit that powerline fills in, but an :inherit at the end of a
;; plist overrides the plist's earlier attributes, including :family; and
;; naming a face there instead loses the background (a darker patch behind the
;; file name, spoiling the separators beside it).  Spaceline inlines
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
    (setq file-face (list (append file-face '(:family "DaddyTimeMono Nerd Font"))))

    (propertize buffer-id
                'face file-face
                'display `(raise ,raise)
                'help-echo help-echo
                'mouse-face (spaceline-all-the-icons--highlight)
                'local-map (make-mode-line-mouse-map 'mouse-1 mouse-f)))
  :tight t)

;; The "file is modified" icon looks small beside the enlarged Lucida Casual
;; (the icon font is not rescaled).  Same as the stock segment, but its size
;; comes from this multiplier instead of the stock 1.1.
(defvar eh-mode-line-modified-icon-scale 1.45
  "Size of the buffer-state icon (modified, saved, read-only) in the mode line.")

(spaceline-define-segment all-the-icons-modified
  "An `all-the-icons' segment depiciting the current buffers state"
  (let* ((buffer-state (format-mode-line "%*"))
         (icon (cond
                ((string= buffer-state "-") (car (spaceline-all-the-icons-icon-set-modified)))
                ((string= buffer-state "*") (cdr (spaceline-all-the-icons-icon-set-modified)))
                ((string= buffer-state "%") "lock"))))

    (propertize (all-the-icons-faicon icon :v-adjust 0.0)
                'face `(:family ,(all-the-icons-faicon-family)
                        :height ,(spaceline-all-the-icons--height eh-mode-line-modified-icon-scale)
                        :inherit)
                'mouse-face (spaceline-all-the-icons--highlight)
                'local-map (make-mode-line-mouse-map 'mouse-1 'read-only-mode)))
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
