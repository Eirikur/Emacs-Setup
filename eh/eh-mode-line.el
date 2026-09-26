;; (set-face-attribute 'mode-line nil :font "LucidaCasual 24" :background 'unspecified  :height 180)  -*- lexical-binding: t; -*-
;;; CHANGING A MODE LINE FONT -- read this first.
;;
;; The mode line is spaceline-all-the-icons: text and icons come from several
;; fonts.  The orange/grey wave dividers ("separators") are NOT font glyphs
;; here: they are small anti-aliased images drawn to an exact pixel height
;; (`eh-mode-line-wave-image' below), because the icon font's wave glyphs never
;; filled the bar (the curves stopped short, the right-hand ones left a flat
;; "toe", and the glyph edge showed a thin coloured line).  Three knobs:
;;
;;  1. Family:  `eh-mode-line-set-fonts' (Lucida Casual on mode-line and
;;     mode-line-inactive).  File-name font: the :family string in the
;;     `all-the-icons-buffer-id' segment (DaddyTimeMono Nerd Font).
;;  2. Size:  the `face-font-rescale-alist' entry.  Its key is the font name,
;;     so change it when you change the family.  Use this, not a face :height.
;;     Icon size: `eh-mode-line-modified-icon-scale' (the modified/lock icon).
;;  3. Bar height:  `eh-mode-line-bar-height' is the pixel height of the
;;     separator images, and it sets the height of the whole bar.  It must be
;;     at least as tall as the tallest text/icon on the line, or the bar is
;;     taller than the images and the curves show a small step at the top and
;;     bottom edge.  Find the number by trial: set it, restart, and read the
;;     bar height with M-: (window-mode-line-height).  It should equal the
;;     value you set (Lucida at 1.2 plus the 1.45 icon needs 84; 82 gave a
;;     bar of 83, i.e. one step).  Bigger just makes the bar taller.
;;
;; Gotchas:
;;  - RESTART Emacs after any of this.  Spaceline compiles the mode line, and
;;    reloading this file into a running Emacs leaves the old one in place.
;;  - The file-name face must be an inner list, `((:height H :family F))'.
;;    Powerline appends the segment's face to whatever list we give it.  A
;;    face symbol, or a bare :inherit at the end, replaces the segment's
;;    background (dark patch behind the name) or overrides :family.
;;  - The separator images ignore Emacs's automatic image scaling
;;    (:scale 1); without that they come out about 2.5x too tall.
;;  - Heights alone can look right in a pixel measurement and still be wrong:
;;    check by eye at 3x zoom.  When testing, do not visit this file in a test
;;    Emacs (a stray keystroke there once ate the hyphen in `use-package').
;;  - The images need a graphical display and XPM support (both Emacs builds
;;    here have it); on a terminal the old icon glyphs are used.

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
;;; family is set on the faces.  Lucida Casual runs small next to Fira Code,
;;; so it is enlarged with `face-font-rescale-alist' rather than a face
;;; :height, which would also scale the icons and spaceline's own sizes.
(add-to-list 'face-font-rescale-alist '("Lucida Casual" . 1.2))

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

;;; Wave separators as images.
;;; The icon font's wave glyphs are shorter than the bar (see the note at the
;;; top), so draw each one as an anti-aliased XPM exactly `eh-mode-line-bar-height'
;;; pixels tall.  The shape is two quarter-ellipses joined by a straight
;;; stretch: region SF (with a tongue at the top) on one side, EF on the other.
(defvar eh-mode-line-bar-height 84
  "Pixel height of the wave separators, which sets the mode line height.")

(defvar eh-mode-line--wave-cache (make-hash-table :test 'equal))

(defun eh-mode-line--rgb (color)
  "COLOR as a list of 0-255 red, green, blue."
  (mapcar (lambda (x) (/ x 257)) (color-values (or color "black"))))

(defun eh-mode-line--wave-boundary (y h w)
  "X of the boundary at pixel row position Y, in a cell H high and W wide."
  (let* ((xm (* 0.5 w)) (y1 (* 0.36 h)) (y2 (* 0.64 h)))
    (cond ((< y y1) (- w (* (- w xm) (sqrt (max 0 (- 1 (expt (/ (- y y1) y1) 2)))))))
          ((<= y y2) xm)
          (t (* xm (sqrt (max 0 (- 1 (expt (/ (- y y2) (- h y2)) 2)))))))))

(defun eh-mode-line-wave-image (dir sf ef)
  "A string that displays a wave separator image.
DIR is \"right\" (SF on the left) or \"left\" (mirrored, SF on the right).
SF and EF are the two colours; the edge is anti-aliased between them."
  (let* ((h eh-mode-line-bar-height)
         (w (round (* 0.52 h)))
         (key (list dir sf ef h)))
    (or (gethash key eh-mode-line--wave-cache)
        (let* ((a (eh-mode-line--rgb sf))
               (b (eh-mode-line--rgb ef))
               (levels 12) (sub 6)
               (mirror (equal dir "left"))
               (rows nil))
          (dotimes (row h)
            (let ((cov (make-vector w 0.0)))
              (dotimes (s sub)
                (let ((xb (eh-mode-line--wave-boundary (+ row (/ (+ s 0.5) sub)) h w)))
                  (dotimes (x w)
                    (aset cov x (+ (aref cov x)
                                   (/ (max 0.0 (min 1.0 (- xb x))) sub))))))
              (push (concat "\"" (mapconcat
                                  (lambda (x)
                                    (char-to-string
                                     (+ ?a (round (* levels (aref cov (if mirror (- w 1 x) x)))))))
                                  (number-sequence 0 (1- w)) "")
                            "\"")
                    rows)))
          (let* ((colors (cl-loop for i from 0 to levels
                                  collect (let ((c (/ (float i) levels)))
                                            (format "\"%c c #%02x%02x%02x\"" (+ ?a i)
                                                    (round (+ (* c (nth 0 a)) (* (- 1 c) (nth 0 b))))
                                                    (round (+ (* c (nth 1 a)) (* (- 1 c) (nth 1 b))))
                                                    (round (+ (* c (nth 2 a)) (* (- 1 c) (nth 2 b))))))))
                 (xpm (concat "/* XPM */\nstatic char *wave[] = {\n"
                              (format "\"%d %d %d 1\",\n" w h (1+ levels))
                              (mapconcat #'identity colors ",\n") ",\n"
                              (mapconcat #'identity (nreverse rows) ",\n") "};\n"))
                 (s (propertize " " 'display (create-image xpm 'xpm t :ascent 'center :scale 1))))
            (puthash key s eh-mode-line--wave-cache)
            s)))))

;; Same as the separator segments in spaceline-all-the-icons-separators.el
;; (macro copied from `define-spaceline-all-the-icons--separator'), except that
;; the wave type draws the image above.  Other types, and terminals, still get
;; the icon glyph.
(defmacro eh-mode-line--define-separator (name direction start-face end-face &optional invert)
  `(spaceline-define-segment
       ,(intern (format "all-the-icons-separator-%s" name))
     (let ((separator (spaceline-all-the-icons-separators--get-type))
           (direction (spaceline-all-the-icons-separators--get-direction ,direction))
           (sf (if (functionp ,start-face) (funcall ,start-face) ,start-face))
           (ef (if (functionp ,end-face) (funcall ,end-face) ,end-face)))
       (when spaceline-all-the-icons-separators-invert-direction
         (setq sf (prog1 ef (setq ef sf))))
       (when (and (eq separator 'slant) (equal direction "left"))
         (setq sf (prog1 ef (setq ef sf))))
       (unless (or (eq separator 'none)
                   (string= (spaceline-all-the-icons--face-background sf)
                            (spaceline-all-the-icons--face-background ef)))
         (if (and (eq separator 'wave) (display-images-p))
             (eh-mode-line-wave-image direction
                                      (spaceline-all-the-icons--face-background sf)
                                      (spaceline-all-the-icons--face-background ef))
           (propertize (all-the-icons-alltheicon (format "%s-%s" separator direction) :v-adjust 0.0)
                       'face `(:height ,(spaceline-all-the-icons--height 1.6)
                               :family ,(all-the-icons-alltheicon-family)
                               :foreground ,(spaceline-all-the-icons--face-background sf)
                               :background ,(spaceline-all-the-icons--face-background ef))))))
     :skip-alternate t :tight t :when (if ,invert (not active) active)))

(eh-mode-line--define-separator left-active-1 "right" spaceline-highlight-face-func 'powerline-active1)
(eh-mode-line--define-separator left-active-2 "right" 'powerline-active1 spaceline-highlight-face-func)
(eh-mode-line--define-separator left-active-3 "right" spaceline-highlight-face-func 'mode-line)
(eh-mode-line--define-separator left-active-4 "right" 'mode-line 'powerline-active2)
(eh-mode-line--define-separator left-extra-1 "right" 'mode-line 'powerline-active1)
(eh-mode-line--define-separator left-extra-2 "right" 'powerline-active1 'powerline-active2)
(eh-mode-line--define-separator right-active-1 "left" 'mode-line 'powerline-active2)
(eh-mode-line--define-separator right-active-2 "left" 'powerline-active1 'mode-line)
(eh-mode-line--define-separator minor-mode-right "right" spaceline-highlight-face-func 'powerline-active2)
(eh-mode-line--define-separator minor-mode-left  "left"  spaceline-highlight-face-func 'powerline-active2)
(eh-mode-line--define-separator left-inactive "right" 'powerline-inactive1 'powerline-inactive2 t)
(eh-mode-line--define-separator right-inactive "left" 'powerline-inactive1 'powerline-inactive2 t)
(eh-mode-line--define-separator paradox-1 "right" spaceline-highlight-face-func 'powerline-active1)
(eh-mode-line--define-separator paradox-2 "right" 'powerline-active1 'powerline-active2)
(eh-mode-line--define-separator paradox-3 "left" 'mode-line 'powerline-active2)
(eh-mode-line--define-separator paradox-4 "right" 'mode-line 'powerline-active2)

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
