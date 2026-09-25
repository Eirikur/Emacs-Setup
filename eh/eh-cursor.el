;;(setq cursor-type '(bar . 5))  
;;(toggle-cursor-type-when-idle 1) ; On when idle
;;(setq cursor-in-non-selected-windows nil)

(use-package beacon
  :init
  (setq
   beacon-blink-when-buffer-changes t
   beacon-blink-delay  4
   beacon-blink-when-focused t)
  :config (beacon-mode t)
  )

;; Cursor
;; (defvar blink-cursor-colors (list  "#92c48f" "#6785c5" "#be369c" "#d9ca65")
;; (defvar blink-cursor-colors (list  "red" "dodger blue" "forest green" "yellow2"))
;; (defvar blink-cursor-colors (list  "red" "dodger blue" "green" "yellow"))
(defvar blink-cursor-colors (list  "#ff2222" "cornflower blue" "green3" "#ffff8f"))
;; (defvar blink-cursor-colors (list  "red" "dodger blue" "green" "#FFFAA0"))

;; (defvar blink-cursor-colors (list  "gray90" "gray80" "gray70" "gray60" "gray50"
;; 				   "gray40", "gray30" "gray20" "gray10"))

(setq-default cursor-type 'box)
(setq cursor-type 'box)
(setq-default curchg-idle-cursor-type 'box x)

(setq blink-cursor-count 0)
(require 'cursor-chg)  ; Load this library
(setq curchg-default-cursor-color "red") ;; "#ffffff")
(set-face-background 'cursor "red")
(blink-cursor-mode 1)
(if (change-cursor-mode)
    (message "change-cursor-mode is running")
  (progn
    (change-cursor-mode 1) ; On for overwrite/read-only/input mode
    (toggle-cursor-type-when-idle 1)))

(defun blink-cursor-timer-function ()
  "Zarza wrote this cyberpunk variant of timer `blink-cursor-timer'.v
   Warning: overwrites original version in `frame.el'.
   This one changes the cursor color on each blink. Define
   colors in blink-cursor-colors'."
  (setq blink-cursor-interval 0.5) ;; EH reset my blink rate
  (when (not (internal-show-cursor-p))
    (when (>= blink-cursor-count (length blink-cursor-colors))
      (setq blink-cursor-count 0))
    (set-cursor-color (nth blink-cursor-count blink-cursor-colors))
    (setq blink-cursor-count (+ 1 blink-cursor-count))
    )
  (internal-show-cursor nil (not  (internal-show-cursor-p)))
  )


;; (require 'cl)
;; (require 'color)

;; (defvar heartbeat-fps 16)
;; (defvar heartbeat-period 5)

;; (defun heartbeat-range (from to cnt)
;;   (Letursor ((step (/ (- to from) (float cnt))))
;;     (loop for i below cnt collect (+ from (* step i)))))

;; (defun heartbeat-cursor-colors ()
;;   (let ((cnt (* heartbeat-period heartbeat-fps)))
;;     (mapcar (lambda (r)
;;               (color-rgb-to-hex r 0 0))
;;             (nconc (heartbeat-range .2 1 (/ cnt 2))
;;                    (heartbeat-range 1 .2 (/ cnt 2))))))

;; (defvar heartbeat-cursor-timer nil)
;; (defvar heartbeat-cursor-old-color)

;; (define-minor-mode heartbeat-cursor-mode
;;   "Change cursor color with the heartbeat effect."
;;   nil "" nil
;;   :global t
;;   (when heartbeat-cursor-timer
;;     (cancel-timer heartbeat-cursor-timer)
;;     (setq heartbeat-cursor-timer nil)
;;     (set-face-background 'cursor heartbeat-cursor-old-color))
;;   (when heartbeat-cursor-mode
;;     (setq heartbeat-cursor-old-color (face-background 'cursor)
;;           heartbeat-cursor-timer
;;           (run-with-timer
;;            0 (/ 1 (float heartbeat-fps))
;;            (lexical-let ((colors (heartbeat-cursor-colors)) tail)
;;              (lambda ()
;;                (setq tail (or (cdr tail) colors))
;;                (set-face-background 'cursor (car tail))))))))

(provide 'eh-cursor) 
