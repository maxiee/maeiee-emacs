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

(defun maeiee-outline--keep-all-entries-visible ()
  "Disable Outline-local folding and reveal every index entry."
  ;; imenu-list 默认在自己的缓冲区启用 Hideshow；关闭时 hs-minor-mode 会先
  ;; 删除已有隐藏 overlay，因此重载本模块也能立刻恢复完整目录。
  (when (bound-and-true-p hs-minor-mode)
    (hs-minor-mode -1)))

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

(defun maeiee-outline--button-location (button-or-event)
  "Return the buffer and position represented by BUTTON-OR-EVENT.

Emacs text buttons pass a marker to their action, while older imenu-list
releases treat that argument as a mouse event.  Accept both contracts so a
click never depends on whichever window happens to be selected."
  (cond
   ;; `insert-button' creates a text button whose action receives a marker.
   ((markerp button-or-event)
    (when-let ((buffer (marker-buffer button-or-event)))
      (cons buffer (marker-position button-or-event))))
   ;; Keep compatibility with overlay buttons and direct position calls.
   ((overlayp button-or-event)
    (when-let ((buffer (overlay-buffer button-or-event)))
      (cons buffer (overlay-start button-or-event))))
   ((integerp button-or-event)
    (cons (current-buffer) button-or-event))
   ;; Also accept a real mouse event if a future imenu-list passes one.
   ((eventp button-or-event)
    (let* ((position-data (event-end button-or-event))
           (window (posn-window position-data))
           (position (posn-point position-data)))
      (when (and (windowp window)
                 (integer-or-marker-p position))
        (cons (window-buffer window)
              (if (markerp position)
                  (marker-position position)
                position)))))))

(defun maeiee-outline--run-button-action (button-or-event action)
  "Run ACTION at the Outline entry represented by BUTTON-OR-EVENT."
  (when-let* ((location
               (maeiee-outline--button-location button-or-event))
              (buffer (car location))
              (position (cdr location)))
    ;; Ignore stale buttons from a replaced or already closed Outline buffer.
    (when (eq buffer (get-buffer imenu-list-buffer-name))
      (with-current-buffer buffer
        (goto-char position)
        (funcall action)))))

(defun maeiee-outline--entry-source-marker (entry)
  "Return ENTRY's source marker when its title carries one.

Org keeps the parent headline marker on the propertized Imenu title even
after Imenu turns that headline into a sublist."
  (let ((title (car-safe entry)))
    (when (and (stringp title) (> (length title) 0))
      (let ((marker (get-text-property 0 'org-imenu-marker title)))
        (and (markerp marker) (marker-buffer marker) marker)))))

(defun maeiee-outline--activate-entry (entry)
  "Open source ENTRY without moving or folding the Outline window."
  (cond
   ;; Org sublists normally lose their selectable Imenu position, but retain
   ;; it as a text property.  Use it so parent headlines navigate like leaves.
   ((maeiee-outline--entry-source-marker entry)
    (let ((marker (maeiee-outline--entry-source-marker entry)))
      (pop-to-buffer (marker-buffer marker))
      (goto-char marker)
      ;; Match Imenu's normal post-jump behavior, including revealing the
      ;; destination in Org, without asking imenu-list to scroll its sidebar.
      (run-hooks 'imenu-after-jump-hook)
      (run-hooks 'imenu-list-after-jump-hook)))
   ;; A generic Imenu group has no source position.  Keep it visible and inert.
   ((imenu--subalist-p entry) nil)
   ;; Leaf entries retain the normal Imenu contract for markers, overlays,
   ;; functions and Eglot positions.
   (t
    (pop-to-buffer imenu-list--displayed-buffer)
    (imenu entry)
    (run-hooks 'imenu-list-after-jump-hook))))

(defun maeiee-outline-goto-entry ()
  "Jump to the Outline entry at point without changing sidebar layout."
  (interactive)
  (when-let ((entry (imenu-list--find-entry)))
    (maeiee-outline--activate-entry entry)))

(defun maeiee-outline-display-entry ()
  "Display the Outline entry at point while retaining sidebar focus."
  (interactive)
  (save-selected-window
    (maeiee-outline-goto-entry)))

(defun maeiee-outline--action-goto-entry (button-or-event)
  "Jump from the clicked Outline button to its source entry."
  (maeiee-outline--run-button-action
   button-or-event #'maeiee-outline-goto-entry))

(defun maeiee-outline--insert-entry (entry depth)
  "Insert ENTRY at DEPTH as a navigation-only Outline button."
  (let* ((sublist-p (imenu--subalist-p entry))
         (title (format "%s" (car entry))))
    (insert (imenu-list--depth-string depth))
    ;; Do not prefix parent entries with `+' or attach a Hideshow action: the
    ;; right sidebar is a complete document map, not a second folding surface.
    (insert-button title
                   'face (imenu-list--get-face depth sublist-p)
                   'help-echo (if (or (not sublist-p)
                                      (maeiee-outline--entry-source-marker entry))
                                  (format "Go to: %s" title)
                                (format "Group: %s" title))
                   'follow-link t
                   'action #'maeiee-outline--action-goto-entry)
    (insert "\n")))
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
  ;; 不跟随正文光标滚动右侧目录，避免折叠、点击或移动光标时视图跳动。
  (imenu-list-update-current-entry nil)
  :config
  ;; 重载模块时不重复安装同一个 advice。
  (unless (advice-member-p #'maeiee-outline--update-from-source
                           'imenu-list-update)
    ;; 保证自动刷新始终从真正的源码缓冲区读取 Imenu 索引。
    (advice-add 'imenu-list-update
                :around #'maeiee-outline--update-from-source))
  ;; 重载旧配置时先移除曾用于折叠父条目的 advice。
  (when (and (fboundp 'maeiee-outline--action-toggle-hs)
             (advice-member-p #'maeiee-outline--action-toggle-hs
                              'imenu-list--action-toggle-hs))
    (advice-remove 'imenu-list--action-toggle-hs
                   #'maeiee-outline--action-toggle-hs))
  ;; 所有行都由同一个稳定按钮渲染，父标题不再变成折叠开关。
  (unless (advice-member-p #'maeiee-outline--insert-entry
                           'imenu-list--insert-entry)
    (advice-add 'imenu-list--insert-entry
                :override #'maeiee-outline--insert-entry))
  ;; 兼容已存在的旧按钮；强制刷新后新按钮也统一执行源码跳转。
  (dolist (action '(imenu-list--action-goto-entry
                    imenu-list--action-toggle-hs))
    (unless (advice-member-p #'maeiee-outline--action-goto-entry action)
      (advice-add action :override #'maeiee-outline--action-goto-entry)))
  ;; imenu-list 自带 hook 会启用 Hideshow；随后关闭它并清除所有隐藏 overlay。
  (add-hook 'imenu-list-major-mode-hook
            #'maeiee-outline--keep-all-entries-visible t)
  ;; 每次刷新后恢复 Maeiee 对侧边窗口生命周期的约定。
  (add-hook 'imenu-list-update-hook #'maeiee-outline--protect-window)
  ;; 原生键位也只负责导航，不再暴露任何目录折叠入口。
  (define-key imenu-list-major-mode-map (kbd "RET")
              #'maeiee-outline-goto-entry)
  (define-key imenu-list-major-mode-map (kbd "SPC")
              #'maeiee-outline-display-entry)
  (define-key imenu-list-major-mode-map (kbd "TAB") nil)
  (define-key imenu-list-major-mode-map (kbd "f") nil)
  ;; 为 Evil normal/motion state 补充与其他列表一致的导航键。
  (evil-define-key '(normal motion) imenu-list-major-mode-map
    (kbd "j") #'next-line
    (kbd "k") #'previous-line
    (kbd "RET") #'maeiee-outline-goto-entry
    (kbd "l") #'maeiee-outline-display-entry
    (kbd "TAB") nil
    (kbd "g") #'imenu-list-refresh
    (kbd "q") #'imenu-list-quit-window)
  ;; 模块重载时，立即清除旧目录留下的折叠 overlay 并重画全部条目。
  (when-let ((outline-buffer (get-buffer imenu-list-buffer-name)))
    (with-current-buffer outline-buffer
      (maeiee-outline--keep-all-entries-visible))
    (when (buffer-live-p imenu-list--displayed-buffer)
      (with-current-buffer imenu-list--displayed-buffer
        (imenu-list-update t)))))
;; 右侧窗口与自动刷新:1 ends here

;; [[file:../modules/52-outline.org::*Leader 菜单入口][Leader 菜单入口:1]]
(with-eval-after-load 'general
  ;; 在现有 window 分组中注册通用 Outline toggle。
  (maeiee-leader
    "w o" '(maeiee-outline-toggle :which-key "outline sidebar")))
;; Leader 菜单入口:1 ends here
