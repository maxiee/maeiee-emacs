;; [[file:../modules/10-ui.org::*配置][配置:1]]
(load-theme 'modus-operandi-tinted t)

(setq-default cursor-type 'bar)
(blink-cursor-mode -1)
(column-number-mode 1)
(global-hl-line-mode 1)

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'visual-line-mode)

(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

(setq frame-title-format
      '(:eval
        (format "%s — Emacs"
                (or (buffer-file-name)
                    (buffer-name)))))

(add-to-list 'default-frame-alist '(width . 118))
(add-to-list 'default-frame-alist '(height . 42))

(defun maeiee-apply-fonts (&optional frame)
  "Apply conservative macOS fonts to FRAME."
  (with-selected-frame (or frame (selected-frame))
    (when (display-graphic-p)
      (when (find-font (font-spec :family "Menlo"))
        (set-face-attribute 'default nil
                            :family "Menlo"
                            :height 150))
      (when (find-font (font-spec :family "PingFang SC"))
        (dolist (charset '(han cjk-misc bopomofo))
          (set-fontset-font t charset
                            (font-spec :family "PingFang SC")
                            nil 'prepend))))))

(add-hook 'after-init-hook #'maeiee-apply-fonts)
(add-hook 'after-make-frame-functions #'maeiee-apply-fonts)
;; 配置:1 ends here
