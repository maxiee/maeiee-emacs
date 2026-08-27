;; [[file:../modules/40-minibuffer.org::*垂直展示候选：Vertico][垂直展示候选：Vertico:1]]
(use-package vertico
  :demand t
  :init
  ;; 全局启用垂直候选列表。
  (vertico-mode 1)
  :custom
  ;; 同时显示足够多的候选，并允许从首尾循环移动。
  (vertico-count 15)
  (vertico-cycle t))
;; 垂直展示候选：Vertico:1 ends here

;; [[file:../modules/40-minibuffer.org::*用多个片段描述目标：Orderless][用多个片段描述目标：Orderless:1]]
(use-package orderless
  :demand t
  :custom
  ;; 一般候选优先使用无序片段匹配，并保留 basic 作为兼容后备。
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  ;; 文件名有路径层级，单独采用适合路径的 partial-completion。
  (completion-category-overrides
   '((file (styles partial-completion)))))
;; 用多个片段描述目标：Orderless:1 ends here

;; [[file:../modules/40-minibuffer.org::*给候选补充判断上下文：Marginalia][给候选补充判断上下文：Marginalia:1]]
(use-package marginalia
  :demand t
  :init
  ;; 为支持的 completion category 全局启用候选注释。
  (marginalia-mode 1))
;; 给候选补充判断上下文：Marginalia:1 ends here

;; [[file:../modules/40-minibuffer.org::*把搜索、缓冲区和跳转接入同一体验：Consult][把搜索、缓冲区和跳转接入同一体验：Consult:1]]
(use-package consult
  :demand t
  :bind
  ;; 保留熟悉的原生和 macOS 入口，同时加入即时预览。
  (("C-s" . consult-line)
   ("C-x b" . consult-buffer)
   ("M-y" . consult-yank-pop)
   ("s-f" . consult-line))
  :config
  ;; 在候选会话中按 < 进入 Consult narrowing。
  (setq consult-narrow-key "<"))

(with-eval-after-load 'general
  ;; General 就绪后，把搜索与缓冲区命令接入既有 Leader 命名空间。
  (maeiee-leader
    "s" '(:ignore t :which-key "search")
    "s s" '(consult-line :which-key "line")
    "s r" '(consult-ripgrep :which-key "ripgrep")
    "s i" '(consult-imenu :which-key "imenu")

    "b b" '(consult-buffer :which-key "switch")))
;; 把搜索、缓冲区和跳转接入同一体验：Consult:1 ends here
