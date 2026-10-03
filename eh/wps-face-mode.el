
;; -*- lexical-binding: t

;; use face-explorer tool

(flyspell-mode)
(set-face-background 'flyspell-incorrect "gray")

(require 'color)
(require 'ct)
;; (require 'palette)
(setq debug-on-error t)

;; "#f5edd6 white #f5deb3 white




(defvar-local wps-heading-cookies nil
  "Face-remap cookies for the org heading faces.")

(define-minor-mode wps-face-mode
  "Remap the default face."
  :localxload- t
  :init-value nil

;;  (require 'eh-org-faces)



  (defface wps-default-face `((t (
				  :background "#f5edd6"
				  :foreground "black" ;; bT"#212f30"
				  :font "Lucida Casual"
				  ))) "My default face.")

(defface org-hide
  '((((background light)) (:foreground "white"))
    (((background dark)) (:foreground "black")))
  "Face used to hide leading stars in headlines.
The foreground color of this face should be equal to the background
color of the frame."
  :group 'org-faces)

  (if wps-face-mode
      (setq wps-hide-modern-face-cookie
            (face-remap-add-relative 'org-modern-tag 'org-hide))
    (face-remap-remove-relative wps-hide-modern-face-cookie))

  (if wps-face-mode
      (setq wps-hide-face-cookie
            (face-remap-add-relative 'org-tag-faces 'org-hide))
    (face-remap-remove-relative wps-hide-face-cookie))


  (if wps-face-mode
      (setq wps-default-face-cookie
            (face-remap-add-relative 'default 'wps-default-face))
    (face-remap-remove-relative wps-default-face-cookie))

  ;; Headings: black in every org level, restored when the mode is turned off.
  (if wps-face-mode
      (setq wps-heading-cookies
            (mapcar (lambda (n)
                      (face-remap-add-relative
                       (intern (format "org-level-%d" n))
                       :foreground "black"))
                    (number-sequence 1 8)))
    (mapc #'face-remap-remove-relative wps-heading-cookies)
    (setq wps-heading-cookies nil))

(setq-local truncate-lines nil)


;; (require 'org-pretty-table)
;; (org-pretty-table-mode)
  ;; (add-hook 'org-mode-hook (lambda () (org-pretty-table-mode)))


);; wps-face-mode minor mode

(defun val-up ()
  (interactive)
  ;; (setq-local wps-bg (nth 0 (ct-rotation-hsluv 1 wps-bg)))
  (setq-local wps-bg (ct-edit-hsluv-h-inc 'wps-bg))
  (message "up")
  ;; (message "%s" wps-bg)
  ;; (sit-for 2)
  ;; (set-face-background 'default 'wps-bg)
  ;; (set-background-color wps-bg)
  )

(defun val-down ()
  (interactive)
  (setq-local wps-bg (ct-edit-hsluv-h-dec wps-bg))
  (message "down")
  ;; (message "%s" wps-bg)
  ;; (sit-for 2)
  (set-face-background 'default wps-bg)
  (set-background-color wps-bg)
  )

;; (keymap-local-set "<wheel-right>" 'text-scale-increase)
;; (keymap-local-set "<wheel-left>" 'text-scale-decrease)
(keymap-local-set "<wheel-right>" 'val-up)
(keymap-local-set "<wheel-left>" 'val-down)

(provide 'wps-face-mode)
