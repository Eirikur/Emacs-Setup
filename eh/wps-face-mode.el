;; -*- lexical-binding: t -*-
;; -*- lexical-binding: t

;; use face-explorer tool

(require 'flyspell)
(set-face-background 'flyspell-incorrect "gray")

(require 'color)
(require 'ct)
;; (require 'palette)

;; "#f5edd6 white #f5deb3 white




(defvar-local wps-heading-cookies nil
  "Face-remap cookies for the org heading faces.")
(defvar-local wps-hide-modern-face-cookie nil "Face-remap cookie.")
(defvar-local wps-hide-face-cookie nil "Face-remap cookie.")
(defvar-local wps-default-face-cookie nil "Face-remap cookie.")

(define-minor-mode wps-face-mode
  "Remap the default face."
  :localxload- t
  :init-value nil
  :keymap (let ((map (make-sparse-keymap)))
            ;; Development hack: reload this file and reapply the mode.
            (define-key map (kbd "C-c W") #'wps-face-reload)
            map)

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
    (when wps-hide-modern-face-cookie (face-remap-remove-relative wps-hide-modern-face-cookie)))

  (if wps-face-mode
      (setq wps-hide-face-cookie
            (face-remap-add-relative 'org-tag-faces 'org-hide))
    (when wps-hide-face-cookie (face-remap-remove-relative wps-hide-face-cookie)))


  (if wps-face-mode
      (setq wps-default-face-cookie
            (face-remap-add-relative 'default 'wps-default-face))
    (when wps-default-face-cookie (face-remap-remove-relative wps-default-face-cookie)))

  ;; Black text for headings and the other org faces that would otherwise
  ;; show in theme colours.  Remapped per buffer, undone when the mode is off.
  ;; Tables use the frame's monospace family: in the proportional font the
  ;; columns (and the org-pretty-table frame) can't line up.
  (if wps-face-mode
      (setq wps-heading-cookies
            (mapcar (lambda (spec)
                      (face-remap-add-relative (car spec) (cdr spec)))
                    (append
                     (mapcar (lambda (n)
                               (cons (intern (format "org-level-%d" n))
                                     '(:foreground "black")))
                             (number-sequence 1 8))
                     (mapcar (lambda (f) (cons f '(:foreground "black")))
                             '(org-document-title org-document-info
                               org-document-info-keyword org-meta-line
                               org-checkbox org-list-dt))
                     `((org-table :foreground "black"
                                  :family ,(face-attribute 'default :family))))))
    (mapc #'face-remap-remove-relative wps-heading-cookies)
    (setq wps-heading-cookies nil))

(setq-local truncate-lines nil)
  (flyspell-mode (if wps-face-mode 1 -1))


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
;; (keymap-local-set "<wheel-right>" 'val-up)
;; (keymap-local-set "<wheel-left>" 'val-down)

(defun wps-face-reload ()
  "Reload wps-face-mode.el and reapply the mode in the current buffer.
Turns the mode off first, so the remaps are removed by the old definition."
  (interactive)
  (let ((file (or (locate-library "wps-face-mode.el")
                  (user-error "Can't find wps-face-mode.el"))))
    (when (bound-and-true-p wps-face-mode)
      (wps-face-mode -1))
    (load file nil t)
    (wps-face-mode 1)
    (message "Reloaded %s" (abbreviate-file-name file))))

(provide 'wps-face-mode)
