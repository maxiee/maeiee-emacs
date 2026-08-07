;; [[file:../modules/51-treemacs.org::*文件树与左侧窗口][文件树与左侧窗口:1]]
(use-package treemacs
  :commands (treemacs)
  :custom
  ;; 把项目文件树固定显示在左侧。
  (treemacs-position 'left)
  ;; 使用适合常见项目名称的初始宽度。
  (treemacs-width 32)
  ;; 第一次打开时定位并展开当前文件所在项目。
  (treemacs-follow-after-init t)
  (treemacs-expand-after-init t)
  :config
  ;; 编辑器切换文件时，让文件树同步选中当前文件。
  (treemacs-follow-mode 1)
  ;; 监听磁盘变化，及时刷新新建、删除或改名的文件。
  (treemacs-filewatch-mode 1))
;; 文件树与左侧窗口:1 ends here

;; [[file:../modules/51-treemacs.org::*项目感知的 toggle][项目感知的 toggle:1]]
(defun maeiee-treemacs-toggle ()
  "Toggle the Treemacs sidebar, adding the current project when needed."
  (interactive)
  ;; 按键首次触发时才加载 Treemacs，避免增加无关启动工作。
  (require 'treemacs)
  ;; 已经显示时关闭；否则加入当前项目并显示文件树。
  (if (eq (treemacs-current-visibility) 'visible)
      (treemacs)
    (treemacs-add-and-display-current-project)))
;; 项目感知的 toggle:1 ends here

;; [[file:../modules/51-treemacs.org::*Evil 导航][Evil 导航:1]]
(use-package treemacs-evil
  :after (treemacs evil))
;; Evil 导航:1 ends here

;; [[file:../modules/51-treemacs.org::*Leader 菜单入口][Leader 菜单入口:1]]
(with-eval-after-load 'general
  (maeiee-leader
    "p t" '(maeiee-treemacs-toggle :which-key "toggle file tree")))
;; Leader 菜单入口:1 ends here
