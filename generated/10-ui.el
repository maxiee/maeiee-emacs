;; [[file:../modules/10-ui.org::*配色主题][配色主题:1]]
;; 加载带有柔和色彩的 Modus Operandi 变体主题。
(load-theme 'modus-operandi-tinted t)
;; 配色主题:1 ends here

;; [[file:../modules/10-ui.org::*光标与状态显示][光标与状态显示:1]]
;; 将光标设置为竖线形状，减少对文字的遮挡。
(setq-default cursor-type 'bar)
;; 关闭光标闪烁，避免长时间阅读时产生视觉干扰。
(blink-cursor-mode -1)
;; 在 mode line 中显示当前列号。
(column-number-mode 1)
;; 高亮当前行，帮助定位正在编辑的位置。
(global-hl-line-mode 1)
;; 光标与状态显示:1 ends here

;; [[file:../modules/10-ui.org::*编辑区域行为][编辑区域行为:1]]
;; 在所有编程模式中打开显示行号的 minor mode。
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
;; 在所有文本模式中打开视觉软换行。
(add-hook 'text-mode-hook #'visual-line-mode)

;; 只有当前 Emacs 提供该函数时才启用精细像素滚动。
(when (fboundp 'pixel-scroll-precision-mode)
  ;; 打开精细像素滚动，提升图形界面中的滚动体验。
  (pixel-scroll-precision-mode 1))
;; 编辑区域行为:1 ends here

;; [[file:../modules/10-ui.org::*Frame 外观][Frame 外观:1]]
;; 设置 Frame 标题，使其显示当前文件或缓冲区名称。
(setq frame-title-format
      ;; 使用动态表达式，让标题随当前缓冲区变化。
      '(:eval
        ;; 按“名称 — Emacs”的格式构造标题。
        (format "%s — Emacs"
                ;; 优先显示当前缓冲区访问的文件路径。
                (or (buffer-file-name)
                    ;; 没有文件时退回到缓冲区名称。
                    (buffer-name)))))

;; 设置新建 Frame 的默认宽度。
(add-to-list 'default-frame-alist '(width . 118))
;; 设置新建 Frame 的默认高度。
(add-to-list 'default-frame-alist '(height . 42))
;; Frame 外观:1 ends here

;; [[file:../modules/10-ui.org::*字体][字体:1]]
;; 定义一个函数，为指定的图形 Frame 应用字体设置。
(defun maeiee-apply-fonts (&optional frame)
  "为 FRAME 应用克制的 macOS 字体设置。"
  ;; 在指定 Frame 中执行后续配置，未指定时使用当前 Frame。
  (with-selected-frame (or frame (selected-frame))
    ;; 终端帧不支持图形字体设置，因此只处理图形帧。
    (when (display-graphic-p)
      ;; 只有系统安装 Menlo 时才将它用作默认拉丁字体。
      (when (find-font (font-spec :family "Menlo"))
        ;; 设置默认字体族为 Menlo。
        (set-face-attribute 'default nil
                            ;; 指定默认字体的名称。
                            :family "Menlo"
                            ;; 设置字体高度，150 表示 15pt。
                            :height 150))
      ;; 只有系统安装 PingFang SC 时才设置中文字体。
      (when (find-font (font-spec :family "PingFang SC"))
        ;; 为中文相关字符集逐一指定字体。
        (dolist (charset '(han cjk-misc bopomofo))
          ;; 将 PingFang SC 插入当前字体集的优先位置。
          (set-fontset-font t charset
                            ;; 指定用于这些字符集的字体。
                            (font-spec :family "PingFang SC")
                            ;; 不限制字体作用的范围。
                            nil 'prepend))))))

;; Emacs 完成初始化后，为已经存在的 Frame 应用字体。
(add-hook 'after-init-hook #'maeiee-apply-fonts)
;; 新建 Frame 后，为它单独应用字体设置。
(add-hook 'after-make-frame-functions #'maeiee-apply-fonts)
;; 字体:1 ends here
