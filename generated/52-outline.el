;; [[file:../modules/52-outline.org::*通用 Outline 命令][通用 Outline 命令:1]]
(defun maeiee-outline-toggle ()
  "Toggle the generic Outline sidebar for the current buffer."
  (interactive)
  ;; 首次使用时才加载通用 Imenu 侧边栏。
  (require 'imenu-list)
  ;; 根据右侧 Outline 当前是否可见，统一执行打开或关闭。
  (imenu-list-smart-toggle))

(defun maeiee-outline--protect-window ()
  "Keep the Outline sidebar when deleting other windows."
  ;; 更新完成后取得 Outline 所在窗口。
  (let ((window (get-buffer-window imenu-list-buffer-name)))
    ;; 只在窗口确实可见时设置侧边栏窗口参数。
    (when window
      ;; 普通的 delete-other-windows 不应顺带关闭结构导航。
      (set-window-parameter window 'no-delete-other-windows t))))

(defun maeiee-outline--update-from-source (update &rest arguments)
  "Run UPDATE in the displayed source when refresh starts in Outline."
  ;; 自动定时器会在当前获得焦点的缓冲区中执行；Outline 自身不是数据源。
  (if (derived-mode-p 'imenu-list-major-mode)
      ;; 根据上一次展示的源码是否仍然存在选择刷新或清理。
      (if (buffer-live-p imenu-list--displayed-buffer)
          ;; 回到源码缓冲区重建 Imenu 索引，避免用 *Ilist* 的空索引覆盖目录。
          (with-current-buffer imenu-list--displayed-buffer
            (apply update arguments))
        ;; 源码已关闭时清空失效目录，不继续显示无法跳转的旧条目。
        (imenu-list-clear))
    ;; 从普通源码缓冲区触发时保持 imenu-list 原来的更新行为。
    (apply update arguments)))
;; 通用 Outline 命令:1 ends here

;; [[file:../modules/52-outline.org::*右侧窗口与自动刷新][右侧窗口与自动刷新:1]]
(use-package imenu-list
  :ensure t
  ;; toggle 首次执行时再加载软件包。
  :commands (imenu-list-smart-toggle)
  :custom
  ;; 与左侧 Treemacs 文件树分居两侧。
  (imenu-list-position 'right)
  ;; 使用足以阅读常见标题和函数名的固定宽度。
  (imenu-list-size 32)
  ;; 保持固定宽度，避免长标题持续挤压正文窗口。
  (imenu-list-auto-resize nil)
  ;; 打开后进入 Outline，便于立即使用键盘导航。
  (imenu-list-focus-after-activation t)
  ;; 当前模式没有 Imenu 数据时清空列表，不遗留上一缓冲区的大纲。
  (imenu-list-persist-when-imenu-index-unavailable nil)
  ;; 空闲时自动重建索引，让新增或移动的结构及时出现。
  (imenu-list-auto-update t)
  ;; 在 Outline 中同步高亮正文光标所在的当前条目。
  (imenu-list-update-current-entry t)
  :config
  ;; 重载模块时不重复安装同一个 advice。
  (unless (advice-member-p #'maeiee-outline--update-from-source
                           'imenu-list-update)
    ;; 保证自动刷新始终从真正的源码缓冲区读取 Imenu 索引。
    (advice-add 'imenu-list-update
                :around #'maeiee-outline--update-from-source))
  ;; 每次刷新后恢复 Maeiee 对侧边窗口生命周期的约定。
  (add-hook 'imenu-list-update-hook #'maeiee-outline--protect-window)
  ;; 为 Evil normal/motion state 补充与其他列表一致的导航键。
  (evil-define-key '(normal motion) imenu-list-major-mode-map
    (kbd "j") #'next-line
    (kbd "k") #'previous-line
    (kbd "RET") #'imenu-list-ret-dwim
    (kbd "l") #'imenu-list-display-dwim
    (kbd "TAB") #'hs-toggle-hiding
    (kbd "g") #'imenu-list-refresh
    (kbd "q") #'imenu-list-quit-window))
;; 右侧窗口与自动刷新:1 ends here

;; [[file:../modules/52-outline.org::*Leader 菜单入口][Leader 菜单入口:1]]
(with-eval-after-load 'general
  ;; 在现有 window 分组中注册通用 Outline toggle。
  (maeiee-leader
    "w o" '(maeiee-outline-toggle :which-key "outline sidebar")))
;; Leader 菜单入口:1 ends here
