;;;; -*- mode: Emacs-Lisp; eldoc-mode:t -*-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Bruce C. Miller - bm3719@gmail.com
;;;; Time-stamp: <2018-07-02 11:27:26 (bm3719)>
;;;;
;;;; This init was created for GNU Emacs 25.1.1 for FreeBSD, GNU/Linux, OSX,
;;;; and Windows, but all or parts of this file should work with older GNU
;;;; Emacs versions, on other OSes, or even on XEmacs with minor adjustments.
;;;;
;;;; External addons used: pabbrev, volatile-highlights.el, paredit, SLIME,
;;;; package.el (clojure-mode, CIDER, ac-cider, projectile, intero, json-mode),
;;;; rainbow-delimiters, geiser, python-mode, AUCTeX, web-mode, rainbow-mode,
;;;; flymake-cursor, js2-mode, markdown-mode, CEDET, gtags,
;;;; aggressive-indent-mode, elscreen, emacs-w3m (development branch),
;;;; multi-term, lusty-explorer, emms, wombat-custom-theme.el, with-editor,
;;;; magit, git-gutter, org-present, xterm-color.el, wttrin.el, lojban-mode (+
;;;; lojban.el), redo+.el, htmlize.el, powerline, diminish.el.
;;;;
;;;; External applications used: aspell, aspell-en, SBCL, Leiningen, stack,
;;;; racket-minimal (+ drracket via raco), GNU Global, python-doc-html,
;;;; pyflakes, Maxima, mutt, w3m, xpp (*nix only), Ghostscript/GSView (Windows
;;;; only), Consolas font (Windows only).

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Initial Startup

;; Getting rid of the toolbar first prevents it from showing in the few seconds
;; needed for the rest of this stuff to load, though disabling it in .Xdefaults
;; is even better.
(when window-system
  (tool-bar-mode -1))

;; Store boolean values for various system-specific settings.
(defvar *freebsd-system* (string-match "freebsd" system-configuration))
(defvar *linux-system* (string-match "linux" system-configuration))
(defvar *nt-system* (string-match "nt" system-configuration))
(defvar *osx-system* (string-match "darwin" system-configuration))

;; Font face: Requires appropriate fonts to be installed.
(if *nt-system*
    (set-default-font
     "-outline-Consolas-normal-r-normal-normal-14-97-96-96-c-*-iso8859-1")
    (when window-system
      (set-face-attribute 'default nil :font "dejavu sans mono-14")))

(setq inhibit-startup-message t)   ; Disable splash screen.
(when window-system
  (set-scroll-bar-mode 'right)     ; If turned on, use right scrollbars.
  (scroll-bar-mode -1)             ; Hide the scroll bar.
  (tooltip-mode 0))                ; Disable tooltips.
(menu-bar-mode -1)                 ; Hide the menu bar.

;; Rearrange the menubars, so it goes tools | buffers | help.
(setq menu-bar-final-items '(tools buffer help-menu))

;; Remove wasted pixels left of col1.
(when (fboundp 'set-fringe-mode)   ; Added in >22.
  (set-fringe-mode 2))             ; Space in pixels.

(global-font-lock-mode 1)          ; Turn on font lock mode everywhere.
(blink-cursor-mode nil)            ; Disable cursor blinking.
(setq visible-bell t)              ; Make bell visible, not aural.

;; Add the directory containing .el files in into the default load path.
(setq load-path (cons "~/.emacs.d/lisp" load-path))

;; Shut off message buffer.  To debug Emacs, comment these out so you can see
;; what's going on.
;;(setq message-log-max nil)
;; Check if message buffer exists before killing (not doing so errors
;; eval-buffer of a .emacs file).
(when (not (eq nil (get-buffer "*Messages*")))
  (kill-buffer "*Messages*"))

;; Provide a useful error trace if loading this .emacs fails.
(setq debug-on-error t)

;; Change backup behavior to save in a directory, not in a miscellany of files
;; all over the place, and disable autosaves completely.
(setq make-backup-files t           ; Do make backups.
      backup-by-copying t           ; Don't clobber symlinks.
      backup-directory-alist
      '(("." . "~/.emacs.d/saves")) ; Don't litter my FS tree.
      delete-old-versions t         ; Get rid of old versions of files.
      kept-new-versions 4
      kept-old-versions 2
      version-control t             ; Use versioned backups.
      auto-save-default nil)        ; Normal backups are enough for me.

;; Specify UTF-8 for a few addons that are too dumb to default to it.
(set-default-coding-systems 'utf-8-unix)

;; Load Common Lisp features.
(require 'cl)

;; Provides zap-up-to-char (M-z), different than the default zap-to-char which
;; includes deleting the argument character.
(load-library "misc")

;; Work-around for a bug in w32 Emacs 23.
(when *nt-system*
  (and (= emacs-major-version 23)
       (defun server-ensure-safe-dir (dir) "Noop" t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Basic Key Bindings

;; Define a function to auto-delete trailing whitespace upon save.
(defun bcm-delete-ws-save ()
  (interactive)
  (progn (delete-trailing-whitespace)
         (save-buffer)))

;; Global key (re-)mappings.
(global-set-key (kbd "C-w") 'backward-kill-word)   ; Match the shell's C-w.
(global-set-key (kbd "C-x w") 'kill-region)
(global-set-key (kbd "C-x s") 'bcm-delete-ws-save)
(global-set-key (kbd "C-m") 'newline-and-indent)
(global-set-key (kbd "M-g") 'goto-line)
(global-set-key (kbd "M-G") 'goto-char)
(global-set-key (kbd "C-x C-k") 'kill-this-buffer) ; Bypasses the C-x k prompt.
(global-set-key (kbd "C-x C-v") 'revert-buffer)
(global-set-key (kbd "C-x TAB") 'indent-region)
(global-set-key (kbd "C-c M-e") 'fixup-whitespace)
(global-set-key (kbd "C-x C-u") 'undo)
(global-set-key (kbd "C-c g") 'replace-string)
(global-set-key (kbd "C-c ;") 'comment-region)
(global-set-key (kbd "C-c '") 'uncomment-region)
(global-set-key (kbd "M-/") 'hippie-expand)        ; Instead of dabbrev-expand.
(global-set-key (kbd "M-z") 'zap-up-to-char)       ; Mimic Vim delete to char.
(global-set-key (kbd "M-o") 'other-window)
(global-set-key (kbd "C-x M-a") 'align-regexp)
(global-set-key (kbd "<f9>") 'insert-char)
;; Move set-fill-column from C-x f to C-x M-f, as it's easy to hit this when
;; intending to do a find-file.
(global-set-key (kbd "C-x f") 'find-file)
(global-set-key (kbd "C-x M-f") 'set-fill-column)
(global-set-key (kbd "C-x C-s") 'bcm-delete-ws-save)

;; For quick macro running.
(global-set-key (kbd "<f10>") 'start-kbd-macro)
(global-set-key (kbd "<f11>") 'end-kbd-macro)
(global-set-key (kbd "<f12>") 'call-last-kbd-macro)

;; Cycle through buffers.
(global-set-key (kbd "<C-tab>") 'bury-buffer)

;; M-x compile and M-x grep mnemonics.
(global-set-key (kbd "<f5>") 'compile)
(global-set-key (kbd "C-c n") 'next-error)
(global-set-key (kbd "C-c p") 'previous-error)

;; My KVM switch uses scroll lock, and Emacs complains about it.
(global-set-key (kbd "<Scroll_Lock>") 'ignore)
;; Silence *-mouse-9 complaints.
(global-set-key (kbd "<mouse-9>") 'ignore)
(global-set-key (kbd "<double-mouse-9>") 'ignore)
(global-set-key (kbd "<drag-mouse-9>") 'ignore)

;; Disable suspend-frame on Xorg sessions.
(when window-system
  (global-unset-key (kbd "C-z"))
  (global-unset-key (kbd "C-x C-z")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; General Text Editing

;; Set fill width to 79 (default was 70).
(setq-default fill-column 79)

;; Takes a multi-line paragraph and makes it into a single line of text.
(defun bcm-unfill-paragraph ()
  "Un-fill paragraph at point."
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))
(global-set-key (kbd "M-p") 'bcm-unfill-paragraph)

;; Heretical tab settings.  Emacs is smart enough to auto-disable this when
;; editing Make files.
(setq-default indent-tabs-mode nil)
;; Using a tab-stop-list will preserve 8-space tabs for documents that have
;; them, but make my own tabs 2 spaces.
(setq tab-stop-list '(2 4 6 8 10 12 14 16 18))
;; (setq-default tab-width 2)

;; Always flash for parens.
(show-paren-mode 1)

;; Enable narrowing of regions.
(put 'narrow-to-region 'disabled nil)

;; Allow a command to erase an entire buffer.
(put 'erase-buffer 'disabled nil)

;; Disable over-write mode.
(defun overwrite-mode (arg) (interactive "p"))

;; Modify hippie-expand functions.
(setq hippie-expand-try-functions-list
      '(try-expand-dabbrev
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-complete-file-name-partially
        try-complete-file-name
        try-expand-all-abbrevs
        try-expand-list
        try-expand-line
        try-complete-lisp-symbol-partially
        try-complete-lisp-symbol))
;; Don't expand symbols.
(setq hippie-expand-dabbrev-as-symbol nil)

;; Use cursor color to indicate some modes.  Modified version that ignores
;; overwrite.  Original snippet from:
;; http://www.emacswiki.org/emacs/EmacsNiftyTricks#toc4
(setq bcm-set-cursor-color-color "")
(setq bcm-set-cursor-color-buffer "")
(defun bcm-set-cursor-color-according-to-mode ()
  "Change cursor color according to some minor modes."
  ;; Set-cursor-color is somewhat costly, so we only call it when needed.
  (let ((color (if buffer-read-only "red" "DarkSlateGray")))
    (unless (and
             (string= color bcm-set-cursor-color-color)
             (string= (buffer-name) bcm-set-cursor-color-buffer))
      (set-cursor-color (setq bcm-set-cursor-color-color color))
      (setq bcm-set-cursor-color-buffer (buffer-name)))))
(add-hook 'post-command-hook 'bcm-set-cursor-color-according-to-mode)

;; Alias to prompt for a regex and a replacement string.
(defalias 'qrr 'query-replace-regexp)

;; Don't bother entering search and replace args if the buffer is read-only.
(defadvice query-replace-read-args (before barf-if-buffer-read-only activate)
  "Signal a `buffer-read-only' error if the current buffer is read-only."
  (barf-if-buffer-read-only))

;; Change pasting behavior.  Normally, it pastes where the mouse is at, which
;; is not necessarily where the cursor is.  This changes things so whether they
;; be middle-click, C-y, or menu, all paste at the cursor.
(setq mouse-yank-at-point t)

;; SavePlace: This puts the cursor in the last place you edited a particular
;; file.  A very useful default Vim feature.
(save-place-mode 1)

;; I use sentences.  Like this.
(setq sentence-end-double-space t)

;; Highlight regions so one can see what one is doing.
;; Defaults on in >23.
(transient-mark-mode 1)

;; Allow for mark ring traversal without popping them off the stack.
(setq set-mark-command-repeat-pop t)

;; Text files supposedly end in new lines, or they should.
(setq require-final-newline t)

;; Defines a function to kill text from point to beginning of line.
(defun bcm-backward-kill-line (arg)
  "Kill chars backward until encountering the end of a line."
  (interactive "p")
  (kill-line 0))
(global-set-key (kbd "M-C-k") 'bcm-backward-kill-line)

;; Copy a line without killing it.
(defun bcm-copy-line (&optional arg)
  "Do a kill-line but copy rather than kill."
  (interactive "p")
  (toggle-read-only 1)
  (kill-line arg)
  (toggle-read-only 0))
;; Replace error message on read-only kill with an echo area message.
(setq-default kill-read-only-ok t)
(global-set-key (kbd "C-x M-w") 'bcm-copy-line)

;; For composing in Emacs then pasting into a word processor, this un-fills all
;; the paragraphs (i.e. turns each paragraph into one very long line) and
;; removes any blank lines that previously separated paragraphs.
(defun bcm-wp-munge ()
  "Un-fill paragraphs and remove blank lines."
  (interactive)
  (let ((save-fill-column fill-column))
    (set-fill-column 1000000)
    (mark-whole-buffer)
    (fill-individual-paragraphs (point-min) (point-max))
    (delete-matching-lines "^$")
    (set-fill-column save-fill-column)))

;; Add a function to strip DOS endlines.
(defun bcm-cut-ctrlm ()
  "Cut all visible ^M."
  (interactive)
  (beginning-of-buffer)
  (while (search-forward "\r" nil t)
         (replace-match "" nil t)))

;; Insert a date string in the format I most commonly use in text files.
(defun bcm-date ()
  "Insert an ISO 8601 formatted date string."
  (interactive)
  (insert (format-time-string "%Y-%m-%d")))
;; Insert a UTC datetime string in ISO 8601 format.
(defun bcm-datetime ()
  "Insert an ISO 8601 formatted datetime string, with time in UTC."
  (interactive)
  (insert (format-time-string "%Y-%m-%dT%H:%M:%SZ" nil 1)))

;; I type a lot of λs.
(global-set-key (kbd "C-M-l") (lambda ()
                                (interactive)
                                (insert-char ?λ)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Buffer Navigation

;; Shift-arrow keys to move between windows.
(windmove-default-keybindings)

;;; Scrolling
;; Fix the whole huge-jumps-scrolling-between-windows nastiness.
(setq scroll-conservatively 4)
;; Don't hscroll unless needed.
(setq hscroll-margin 1)
;; Start scrolling when 2 lines from top/bottom.  Set to 0 on systems where I
;; use ansi-term or multi-term a lot.
(setq scroll-margin 0)
;; Keeps the cursor in the same relative row during pgups and downs.
(setq scroll-preserve-screen-position t)

;;; Mouse wheel scrolling
;; Scroll in 1-line increments for the buffer under pointer.
(setq mouse-wheel-follow-mouse t)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))

;; Make cursor stay in the same column when scrolling using pgup/dn.
;; Previously pgup/dn clobbers column position, moving it to the beginning of
;; the line.
;; http://www.dotemacs.de/dotfiles/ElijahDaniel.emacs.html
(defadvice scroll-up (around ewd-scroll-up first act)
  "Keep cursor in the same column."
  (let ((col (current-column)))
    ad-do-it
    (move-to-column col)))
(defadvice scroll-down (around ewd-scroll-down first act)
  "Keep cursor in the same column."
  (let ((col (current-column)))
    ad-do-it
    (move-to-column col)))

;; Change C-x C-b behavior so it uses bs; shows only interesting buffers.
(global-set-key (kbd "C-x C-b") 'bs-show)

;; The first invocation of Home/End moves to the beginning of the *text* line.
;; A second invocation moves the cursor to beginning of the *absolute* line.
;; Most of the time this won't matter even be noticeable, but when it does (in
;; comments, for example) it will quite convenient.  By sw77@cornell.edu.
(global-set-key (kbd "<home>") 'bcm-my-smart-home)
(global-set-key (kbd "<end>") 'bcm-my-smart-end)
(defun bcm-my-smart-home ()
  "Odd home to beginning of line, even home to beginning of text/code."
  (interactive)
  (if (and (eq last-command 'bcm-my-smart-home)
           (/= (line-beginning-position) (point)))
      (beginning-of-line)
      (beginning-of-line-text)))
(defun bcm-my-smart-end ()
  "Odd end to end of line, even end to begin of text/code."
  (interactive)
  (if (and (eq last-command 'bcm-my-smart-end)
           (= (line-end-position) (point)))
      (bcm-end-of-line-text)
      (end-of-line)))
(defun bcm-end-of-line-text ()
  "Move to end of current line and skip comments and trailing space."
  (interactive)
  (end-of-line)
  (let ((bol (line-beginning-position)))
    (unless (eq font-lock-comment-face (get-text-property bol 'face))
      (while (and (/= bol (point))
                  (eq font-lock-comment-face
                      (get-text-property (point) 'face)))
             (backward-char 1))
      (unless (= (point) bol)
        (forward-char 1) (skip-chars-backward " \t\n")))))
;; Normal home/end prefixed with control.
(global-set-key (kbd "C-<home>") 'beginning-of-buffer)
(global-set-key (kbd "C-<end>") 'end-of-buffer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Miscellaneous Customization

;; This sets garbage collection to hundred times of the default; supposedly
;; significantly speeds up startup time.  Disable this if RAM is limited.
(setq gc-cons-threshold 50000000)

;; Warn only when opening files bigger than 100MB (default is 10MB).
(setq large-file-warning-threshold 100000000)

;; Prevent windows from getting too small.
(setq window-min-height 3)

;; Show column number in mode line.
(setq column-number-mode t)

;; Variables to mark as safe.
(setq safe-local-variable-values '((outline-minor-mode . t)
                                   (eldoc-mode . t)))

;; Set shells.
(when *freebsd-system*
  (setq shell-file-name "/usr/local/bin/zsh")
  (setq tex-shell-file-name "/usr/local/bin/zsh"))
(when *linux-system*
  (setq shell-file-name "/usr/bin/zsh")
  (setq tex-shell-file-name "/usr/bin/zsh"))
(when *nt-system*
  (setq shell-file-name "/usr/bin/bash")
  (setq tex-shell-file-name "/usr/bin/bash"))
(when *osx-system*
  (setq shell-file-name "/bin/zsh")
  (setq tex-shell-file-name "/bin/zsh"))

;; Answer 'y' or RET for yes and 'n' for no at minibar prompts.
(defalias 'yes-or-no-p 'y-or-n-p)
(define-key query-replace-map (kbd "RET") 'act)

;; Always use the echo area instead of dialog boxes in console mode.
(when (not window-system)
  (setq use-dialog-box nil))

;; Don't echo passwords when communicating with interactive programs.
(add-hook 'comint-output-filter-functions 'comint-watch-for-password-prompt)

;; Gets rid of disabled commands prompting.
(setq disabled-command-hook nil)

;; Allow seamless editing of files in a tar/jar/zip file.
(auto-compression-mode 1)

;; We can also get completion in the mini-buffer as well.
(icomplete-mode t)

;; Completion ignores case.
(setq read-buffer-completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)
;; In Emacs <23, use the following.
;; (setq completion-ignore-case t)

;; Completion ignores filenames ending in any string in this list.
(setq completion-ignored-extensions
      '(".o" ".elc" ".class" "java~" ".ps" ".abs" ".mx" ".~jv" ".bak" ))

;; Startup message with Emacs version.  Modified from original at:
;; http://www.emacswiki.org/emacs/DotEmacsChallenge
(defun bcm-emacs-reloaded ()
  "Display animated startup message."
  (animate-string
   (concat ";; Initialization successful.  Welcome to "
           (substring (emacs-version) 0 16) ".") 0 0)
  (newline-and-indent)  (newline-and-indent))
(add-hook 'after-init-hook 'bcm-emacs-reloaded)

;; Call this function to increase/decrease font size.
(defun bcm-zoom (n)
  "With positive N, increase the font size, otherwise decrease it."
  (set-face-attribute 'default (selected-frame) :height
                      (+ (face-attribute 'default :height)
                         (* (if (> n 0) 1 -1) 10))))
;; Add some zoom keybindings.
(global-set-key (kbd "C-+") '(lambda () (interactive) (bcm-zoom 1)))
(global-set-key (kbd "C-<kp-add>") '(lambda () (interactive) (bcm-zoom 1)))
(global-set-key (kbd "C--") '(lambda () (interactive) (bcm-zoom -1)))
(global-set-key (kbd "C-<kb-subtract>") '(lambda () (interactive) (bcm-zoom -1)))

;;; Time-stamp support
;; When there is a "Time-stamp: <>" in the first 10 lines of the file,
;; Emacs will write time-stamp information there when saving.
(setq time-stamp-active t          ; Do enable time-stamps.
      time-stamp-line-limit 10     ; Check first 10 buffer lines for stamp.
      time-stamp-format "%04y-%02m-%02d %02H:%02M:%02S (%u)") ; Date format.
(add-hook 'write-file-hooks 'time-stamp) ; Update when saving.

;; Follow the compilation buffer scroll instead of remaining at the top line.
(setq compilation-scroll-output t)

;; I always compile my .emacs, saving about two seconds startup time.  But that
;; only helps if the .emacs.elc is newer than the .emacs.  So, compile .emacs
;; if it's not.
(defun bcm-autocompile ()
  "Compile self in ~/.emacs.d/build"
  (interactive)
  (require 'bytecomp)
  (if (string= (buffer-file-name)
               (expand-file-name
                (concat default-directory "~/.emacs.d/build")))
      (byte-compile-file (buffer-file-name))))
(add-hook 'after-save-hook 'bcm-autocompile)

;; A function to close all buffers except scratch.
(defun bcm-cleanup ()
  "Kill all buffers except *scratch*."
  (interactive)
  (mapcar (lambda (x) (kill-buffer x)) (buffer-list)) (delete-other-windows))

;; Indents the entire buffer according to whatever indenting rules are present.
(defun bcm-indent ()
  "Indent whole buffer."
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))
;; This is so commonly used, binding to F4.
(global-set-key (kbd "<f4>") 'bcm-indent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Built-in Modes

;;; Color themes
;; Define where to find themes for M-x load-theme and load wombat-custom.
(when (and (>= emacs-major-version 24) window-system)
  (add-to-list 'custom-theme-load-path "~/.emacs.d/lisp/themes")
  (load-theme 'wombat-custom t nil))

;;; emacs-lisp-mode
(add-hook 'emacs-lisp-mode-hook 'flyspell-prog-mode)
(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
;;; IELM
(add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)

;;; prettify-symbols-mode
;; Build a symbols-alist for Haskell (which is all I'm using this for
;; currently). I might split these off into a different file if I create more
;; for other languages.
(defvar haskell-prettify-symbols-alist
  '(;; Double-struck letters
    ("|A|" . ?𝔸) ("|B|" . ?𝔹) ("|C|" . ?ℂ) ("|D|" . ?𝔻) ("|E|" . ?𝔼)
    ("|F|" . ?𝔽) ("|G|" . ?𝔾) ("|H|" . ?ℍ) ("|I|" . ?𝕀) ("|J|" . ?𝕁)
    ("|K|" . ?𝕂) ("|L|" . ?𝕃) ("|M|" . ?𝕄) ("|N|" . ?ℕ) ("|O|" . ?𝕆)
    ("|P|" . ?ℙ) ("|Q|" . ?ℚ) ("|R|" . ?ℝ) ("|S|" . ?𝕊) ("|T|" . ?𝕋)
    ("|U|" . ?𝕌) ("|V|" . ?𝕍) ("|W|" . ?𝕎) ("|X|" . ?𝕏) ("|Y|" . ?𝕐)
    ("|Z|" . ?ℤ) ("|gamma|" . ?ℽ) ("|Gamma|" . ?ℾ) ("|pi|" . ?ℼ) ("|Pi|" . ?ℿ)
    ;; Types
    ("::" . ?∷)
    ;; Quantifiers
    ("forall" . ?∀) ("exists" . ?∃)
    ;; Arrows
    ("->" . ?→) ("-->" . ?⟶) ("<-" . ?←) ("<--" . ?⟵) ("<->" . ?↔)
    ("<-->" . ?⟷)
    ;; Double arrows
    ("=>" . ?⇒) ("==>" . ?⟹) ("<==" . ?⟸) ("<=>" . ?⇔) ("<==>" . ?⟺)
    ;; Bar arrows
    ("|->" . ?↦) ("|-->" . ?⟼) ("<-|" . ?↤) ("<--|" . ?⟻)
    ;; Double bar arrows
    ("|=>" . ?⤇) ("|==>" . ?⟾) ("<=|" . ?⤆) ("<==|" . ?⟽)
    ;; Squiggle arrows
    ("~>" . ?⇝) ("<~" . ?⇜)
    ;; Tail arrows
    (">->" . ?↣) ("<-<" . ?↢) ("->>" . ?↠) ("<<-" . ?↞)
    ;; Two-headed tail arrows
    (">->>" . ?⤖) ("<<-<" . ?⬻)
    ;; Open-headed arrows
    ("<|-" . ?⇽) ("-|>" . ?⇾) ("<|-|>" . ?⇿)
    ;; Arrows with stroke
    ("<-/-" . ?↚) ("-/->" . ?↛)
    ;; Arrows with vertical stroke
    ("<-|-" . ?⇷) ("-|->" . ?⇸) ("<-|->" . ?⇹)
    ;; Arrows with double vertical stroke
    ("<-||-" . ?⇺) ("-||->" . ?⇻) ("<-||->" . ?⇼)
    ;; Circle arrows
    ("-o->" . ?⇴) ("<-o-" . ?⬰)
    ;; Boolean operators
    ("not" . ?¬) ("&&" . ?∧) ("||" . ?∨)
    ;; Relational operators
    ("==" . ?≡) ("/=" . ?≠) ("<=" . ?≤) (">=" . ?≥) ("/<" . ?≮) ("/>" . ?≯)
    ;; Containers / Collections
    ("++" . ?⧺) ("+++" . ?⧻) ("|||" . ?⫴) ("empty" . ?∅) ("elem" . ?∈)
    ("notElem" . ?∉) ("member" . ?∈) ("notMember" . ?∉) ("union" . ?∪)
    ("intersection" . ?∩) ("isSubsetOf" . ?⊆) ("isProperSubsetOf" . ?⊂)
    ;; Other
    ("<<" . ?≪) (">>" . ?≫) ("<<<" . ?⋘) (">>>" . ?⋙) ("<|" . ?⊲) ("|>" . ?⊳)
    ("><" . ?⋈) ("mempty" . ?∅) ("mappend" . ?⊕) ("<*>" . ?⊛) ("undefined" . ?⊥)
    (":=" . ?≔) ("=:" . ?≕) ("=def" . ?≝) ("=?" . ?≟) ("..." . ?…)))
(defun bcm-haskell-prettify-enable ()
  "Enable prettification for Haskell symbols."
  (prettify-symbols-mode -1)
  (setq-local prettify-symbols-alist (append prettify-symbols-alist
                                             haskell-prettify-symbols-alist))
  (prettify-symbols-mode))

;;; c-mode
;; Resize the compilation window so that it doesn't take up half the frame.
(setq compilation-window-height 16)
;; Always scroll the compilation window.
(setq compilation-scroll-output t)
;; If there were no errors, there's not much to look at in a compilation
;; buffer, so make it go away in 2 seconds.
(setq compilation-finish-function
      (lambda (buf str)
        (if (or (string-match "exited abnormally" str)
                (string-match (buffer-name buf) "*grep*"))
            ;; There were errors.
            (message "Compilation errors, press C-x ` to visit.")
            ;; No errors; make the compilation window go away in 2 seconds.
            (run-at-time 2 nil 'delete-windows-on buf)
            (message "Build Succeeded."))))
;; Use c-mode for flex files (cc-mode is probably better for this though).
(setq auto-mode-alist
      (append '(("\\.l$" . c-mode))
              auto-mode-alist))
;; Change default indent style from "gnu".  I actually use 1TBS, but BSD style
;; auto-indents properly.
(setq c-default-style "bsd"
      c-basic-offset 4)
;; Spell-check comments.
(add-hook 'c-mode-hook 'flyspell-prog-mode)

;;; java-mode
;; This mode doesn't properly indent Java out of the box.  This combined with
;; the C settings above fixes that.
(add-hook 'java-mode-hook
          (lambda ()
            "Treat Java 1.5 @-style annotations as comments."
            (setq c-comment-start-regexp "(@|/(/|[*][*]?))")
            (modify-syntax-entry ?@ "< b" java-mode-syntax-table)))

;;; sql-mode
;; This adds a connection for my local (and only locally-accessible) l1j-en
;; test database on MySQL, with the ability to add others later by appending to
;; sql-connection-alist.
(setq sql-connection-alist
      '((pool-a
         (sql-product 'mysql)
         (sql-server "127.0.0.1")
         (sql-user "root")
         (sql-password "lintest")
         (sql-database "l1jdb")
         (sql-port 3306))))
(defun sql-connect-preset (name)
  "Connect to a predefined SQL connection listed in `sql-connection-alist'."
  (eval `(let ,(cdr (assoc name sql-connection-alist))
           (flet ((sql-get-login (&rest what)))
             (sql-product-interactive sql-product)))))
;; Execute this function to log in.
(defun sql-pool-a ()
  "Connect to SQL pool 0."
  (interactive)
  (sql-connect-preset 'pool-a))
;; Use sql-mode for .script files (used by Jetty and Tomcat).
(add-to-list 'auto-mode-alist '("\\.script$" . sql-mode))
;; Add an auto-mode for the HiveQL extension I use.
(add-to-list 'auto-mode-alist '("\\.hql$" . sql-mode))

;;; flymake
;; See flymake-cursor entry for minibuffer fix.
(global-set-key (kbd "C-c [") 'flymake-goto-prev-error)
(global-set-key (kbd "C-c ]") 'flymake-goto-next-error)

;;; prolog-mode
(autoload 'prolog-mode "prolog" "Major mode for editing Prolog programs." t)
(autoload 'run-prolog "prolog" "Start a Prolog sub-process." t)
(setq prolog-system 'swi)
(setq prolog-program-switches
      '((sicstus ("-i")) (swi ("-L0" "-G0" "-T0" "-A0")) (t nil)))
;; By default, .pl is linked to perl-mode.
(add-to-list 'auto-mode-alist '("\\.pl$" . prolog-mode))
;; Add auto-mode for Mercury source, which is close enough to Prolog to benefit
;; from syntax highlighting.  This overrides the default ObjC auto-mode for .m.
(setq auto-mode-alist (cons '("\\.m$" . prolog-mode) auto-mode-alist))

;;; cperl-mode
;; Always use cperl-mode instead of perl-mode.
(defalias 'perl-mode 'cperl-mode)
;; (add-to-list 'auto-mode-alist '("\\.pl$" . cperl-mode))
(add-to-list 'auto-mode-alist '("\\.cgi$" . cperl-mode))
(add-to-list 'auto-mode-alist '("\\.pm$" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("perl" . cperl-mode))

;;; nxml-mode
;; Using nXhtml for .xhtml files instead of XHTML (an sgml-mode mode).
(setq auto-mode-alist
      (cons '("\\.\\(xml\\|xsl\\|rng\\|xhtml\\)\\'" . nxml-mode)
            auto-mode-alist))

;;; conf-mode
;; Ignore single quote highlighting in .properties files.
(add-hook 'conf-javaprop-mode-hook
          '(lambda () (conf-quote-normal nil)))

;;; shell-mode
;; Use ANSI colors within shell-mode.
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;;; flyspell
;; Turn on flyspell mode for text editing.
(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))
(dolist (hook '(change-log-mode-hook log-edit-mode-hook))
  (add-hook hook (lambda () (flyspell-mode -1))))
;; aspell > ispell
;; Suggestion mode tuned to fastest possible.
(setq ispell-program-name "aspell"
      ispell-extra-args '("--sug-mode=ultra"))
;; Solves aspell startup problem on some Linuxes.
(setq flyspell-issue-welcome-flag nil)
;; Some OSX-specific cocoAspell config.
(when *osx-system*
  (setq ispell-program-name "aspell"
        ispell-dictionary "english"
        ispell-dictionary-alist
        (let ((default '("[A-Za-z]" "[^A-Za-z]" "[']" nil
                         ("-B" "-d" "english" "--dict-dir"
                          "/Library/Application Support/cocoAspell/aspell6-en-6.0-0")
                         nil iso-8859-1)))
          `((nil ,@default)
            ("english" ,@default))))
  (add-to-list 'exec-path "/usr/local/bin"))

;;; org-mode
;; Initiate org-mode when opening .org files.
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
;; Stores links.  In an org-mode file, C-c C-l calls them and creates links.
(global-set-key (kbd "C-x M-l") 'org-store-link)
;; org-agenda displays this week's scheduled items.
(global-set-key (kbd "C-x M-a") 'org-agenda)
;; Change default TODO keywords and coloring.
(setq
 org-src-fontify-natively t
 org-todo-keywords (quote ((sequence
                            "TODO(t)"
                            "STARTED(s!)"
                            "|"
                            "DONE(d!/!)"
                            "CANCELED(c!)")))
 org-todo-keyword-faces
 (quote (("TODO" :foreground "red" :weight bold)
         ("STARTED" :foreground "blue" :weight bold)
         ("DONE" :foreground "forest green" :weight bold)
         ("CANCELED" :foreground "light sky blue" :weight bold))))
(add-hook 'org-mode-hook 'turn-on-auto-fill)

;;; org-capture.el: On-the-fly note taking.
(setq org-default-notes-file "~/notes.org")
;; Global keybinding for idea capture.
(global-set-key (kbd "C-c r") 'org-capture)

;;; add-log
;; Auto-add new entry to CHANGELOG found up parent dir hierarchy with C-x 4 a.
(setq user-mail-address "bm3719@gmail.com")  ; Default: user@host
(setq change-log-default-name "CHANGELOG")   ; Default: ChangeLog

;;; savehist-mode
;; Mode requires customization set prior to enabling.
(setq savehist-additional-variables
      '(search-ring regexp-search-ring)    ; Save search entries.
      savehist-file "~/.emacs.d/savehist") ; Keep this out of ~.
(savehist-mode t)                          ; Turn savehist-mode on.

;;; calendar
;; Add calendar control-navigation.
(add-hook 'calendar-load-hook
          '(lambda ()
            (define-key calendar-mode-map (kbd "C-x >") 'scroll-calendar-right)
            (define-key calendar-mode-map (kbd "C-x <") 'scroll-calendar-left)))
;; Change some self-explanatory calendar settings.
(setq
 mark-holidays-in-calendar t
 all-christian-calendar-holidays t
 all-islamic-calendar-holidays nil
 all-hebrew-calendar-holidays nil
 display-time-24hr-format t)

;;; diary
(setq diary-file "~/.emacs.d/.diary")    ; Might as well keep this out of ~.
(setq mark-diary-entries-in-calendar t)  ; Add entries to calendar.

;;; tetris
(setq tetris-score-file "~/.emacs.d/tetris-scores") ; Moved from ~.

;;; rmail
(setq mail-archive-file-name "~/Mail/sent")  ; Reuse the gnus mail dir.
(defconst user-mail-address "bm3719@gmail.com")

;;; woman
;; Alias man to woman, since the latter offers completion.
(defalias 'man 'woman)

;;; Emacs bookmarks
;; NOTE: C-x r m: create new bookmark, C-x r b: navigate to bookmark, C-x r l:
;;       list bookmarks.
(setq
 bookmark-default-file "~/.emacs.d/bookmarks" ; Moved from ~.
 bookmark-save-flag 1)                        ; Autosave each change.

;; Extra miscellaneous mode associations.
(setq auto-mode-alist (cons '("\\.plan$" . text-mode) auto-mode-alist)
      auto-mode-alist (cons '("\\.project$" . text-mode) auto-mode-alist)
      auto-mode-alist (cons '("\\.doc$" . text-mode) auto-mode-alist)
      auto-mode-alist (cons '("\\.zsh$" . sh-mode) auto-mode-alist)
      auto-mode-alist (cons '("\\CHANGELOG$" . text-mode) auto-mode-alist)
      auto-mode-alist (cons '("\\INSTALL$" . text-mode) auto-mode-alist)
      auto-mode-alist (cons '("\\README$" . text-mode) auto-mode-alist)
      auto-mode-alist (cons '("\\TODO$" . text-mode) auto-mode-alist))

;; Custom generic mode for arff files (Used with Weka).
(require 'generic)
(define-generic-mode 'arff-file-mode
    (list ?%)
  (list "attribute" "relation" "end" "data")
  '(("\\('.*'\\)" 1 'font-lock-string-face)
    ("^\\@\\S-*\\s-\\(\\S-*\\)" 1 'font-lock-string-face)
    ("^\\@.*\\(real\\)" 1 'font-lock-type-face)
    ("^\\@.*\\(integer\\)" 1 'font-lock-type-face)
    ("^\\@.*\\(numeric\\)" 1 'font-lock-type-face)
    ("^\\@.*\\(string\\)" 1 'font-lock-type-face)
    ("^\\@.*\\(date\\)" 1 'font-lock-type-face)
    ("^\\@.*\\({.*}\\)" 1 'font-lock-type-face)
    ("^\\({\\).*\\(}\\)$" (1 'font-lock-reference-face)
     (2 'font-lock-reference-face))
    ("\\(\\?\\)" 1 'font-lock-reference-face)
    ("\\(\\,\\)" 1 'font-lock-keyword-face)
    ("\\(-?[0-9]+?.?[0-9]+\\)" 1 'font-lock-constant-face)
    ("\\(\\@\\)" 1 'font-lock-preprocessor-face))
  (list "\.arff?")
  (list
   (function
    (lambda ()
     (setq font-lock-defaults
           (list 'generic-font-lock-defaults nil t   ; case insensitive
                 (list (cons ?* "w") (cons ?- "w"))))
     (turn-on-font-lock)))) "Mode for arff-files.")

;; Use file<pathname> instead of file<n> to uniquify buffer names.
;; Note: Enabled by default in >=24.4.
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

;;; server-mode
;; This starts up a server automatically, allowing emacsclient to connect to a
;; single Emacs instance.  If a server already exists, it is killed.
(server-force-delete)
(server-start)

;;; comint-mode
;; Various comint settings.
(setq comint-scroll-to-bottom-on-input t
      comint-scroll-to-bottom-on-output nil
      comint-scroll-show-maximum-output t
      ;; Match most shells' insert of space/slash after file completion.
      comint-completion-addsuffix t
      comint-buffer-maximum-size 100000
      comint-input-ring-size 5000)

;;; TRAMP
(when *nt-system*
  (setq shell-file-name "bash")
  (setq explicit-shell-file-name shell-file-name))
(setq tramp-default-method "scp")

;;; icomplete.el
;; Disable icomplete, since I prefer using lusty-explorer for this and don't
;; want both enabled.
(icomplete-mode 0)

;;; CEDET
;; Included in Emacs >=23.2.
(setq semantic-load-turn-useful-things-on t)
;; Keep semantic.cache files from littering my FS.
(setq semanticdb-default-save-directory "~/.emacs.d/saves/semantic.cache")
(require 'cedet)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; External Addons

;; Add all ~/.emacs.d/lisp subfolders to load path.
(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
    (let* ((my-lisp-dir "~/.emacs.d/lisp")
           (default-directory my-lisp-dir))
      (add-to-list 'load-path my-lisp-dir)
      (normal-top-level-add-subdirs-to-load-path)))

;;; package.el
(require 'package)
(setq package-enable-at-startup nil)
(package-initialize)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
;; (add-to-list 'package-archives
;;              '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives
             '("melpa-stable" . "http://stable.melpa.org/packages/"))
(when (boundp 'package-pinned-packages)
  (setq package-pinned-packages
        '((clojure-mode . "melpa-stable")
          (cider . "melpa-stable")
          (ac-cider . "melpa-stable")
          (projectile . "melpa-stable")
          (intero . "melpa-stable")
          (json-mode . "mepla-stable"))))
(defvar my-packages '(clojure-mode
                      cider
                      ac-cider
                      projectile
                      intero
                      json-mode))
(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

;;; pabbrev:
;; Add this to the mode-hook for any major modes I want this lightweight
;; completion auto-activated.
;; https://github.com/phillord/pabbrev
(require 'pabbrev)
;; Disable minibuffer message when expansion occurs.
(setq pabbrev-idle-timer-verbose nil)

;;; volatile-highlights.el
;; https://github.com/k-talo/volatile-highlights.el
(require 'volatile-highlights)
(volatile-highlights-mode t)

;;; paredit
;; http://mumble.net/~campbell/emacs/paredit.el
(require 'paredit)
(add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook #'enable-paredit-mode)
(add-hook 'lisp-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook #'enable-paredit-mode)
(add-hook 'geiser-repl-mode-hook #'enable-paredit-mode)

;;; SLIME
;; http://common-lisp.net/project/slime/
(when (or *freebsd-system* *osx-system*) ; FreeBSD CVS version.
  (setq inferior-lisp-program "/usr/local/bin/sbcl"
        common-lisp-hyperspec-root
        "file:///usr/local/share/doc/clisp-hyperspec/HyperSpec/"))
(when *linux-system*   ; Linux CVS version (only using with remote SBCL).
  (setq inferior-lisp-program "/usr/bin/sbcl"
        common-lisp-hyperspec-root "file:///home/bm3719/doc/HyperSpec/"))
(when *nt-system*      ; Windows CVS version.
  (setq inferior-lisp-program "sbcl.exe"
        common-lisp-hyperspec-root "file:///C:/bm3719/doc/HyperSpec/"))
;; Common SLIME setup.
(setq lisp-indent-function 'common-lisp-indent-function
      slime-complete-symbol-function 'slime-fuzzy-complete-symbol
      slime-startup-animation t
      slime-complete-symbol*-fancy t)
(require 'slime)

;; Startup SLIME when a Lisp file is open.
(add-hook 'lisp-mode-hook
          (lambda ()
            (slime-mode t)
            (local-set-key (kbd "C-c s") 'slime-selector)))
(add-hook 'inferior-lisp-mode-hook
          (lambda ()
            (inferior-slime-mode t)
            (local-set-key (kbd "C-c s") 'slime-selector)))

;; SLIME contribs.
(slime-setup '(slime-autodoc       ; Show information about symbols near point.
               slime-fancy         ; Some fancy SLIME contribs.
               slime-banner        ; Persistent header line, startup animation.
               slime-asdf          ; ASDF support.
               slime-indentation)) ; Customizable indentation.
;; Indentation customization.
(setq lisp-lambda-list-keyword-parameter-alignment t)
(setq lisp-lambda-list-keyword-alignment t)
;; SLIME contribs init.
(slime-banner-init)          ; Sets banner function to slime-startup-message.
(slime-asdf-init)            ; Hooks slime-asdf-on-connect.
;; Spell-check comments.
(add-hook 'slime-mode-hook 'flyspell-prog-mode)
(add-hook 'slime-mode-hook 'paredit-mode)
(add-hook 'slime-repl-mode-hook 'paredit-mode)

;; Translates from Emacs buffer to filename on remote machine.
(setf slime-translate-to-lisp-filename-function
      (lambda (file-name)
        (subseq file-name (length "/ssh:[userid]:")))
      slime-translate-from-lisp-filename-function
      (lambda (file-name)
        (concat "/[userid]:" file-name)))

;; Fontify *slime-description* buffer.
(defun slime-description-fontify ()
  "Fontify sections of SLIME Description."
  (with-current-buffer "*slime-description*"
    (highlight-regexp
     (concat "^Function:\\|"
             "^Macro-function:\\|"
             "^Its associated name.+?) is\\|"
             "^The .+'s arguments are:\\|"
             "^Function documentation:$\\|"
             "^Its.+\\(is\\|are\\):\\|"
             "^On.+it was compiled from:$")
     'hi-blue)))
(defadvice slime-show-description (after slime-description-fontify activate)
  "Fontify sections of SLIME Description."
  (slime-description-fontify))

;; Improve usability of slime-apropos: slime-apropos-minor-mode
(defvar slime-apropos-anchor-regexp "^[^ ]")
(defun slime-apropos-next-anchor ()
  "Navigate to next SLIME apropos anchor."
  (interactive)
  (let ((pt (point)))
    (forward-line 1)
    (if (re-search-forward slime-apropos-anchor-regexp nil t)
        (goto-char (match-beginning 0))
        (goto-char pt)
        (error "anchor not found"))))
(defun slime-apropos-prev-anchor ()
  "Navigate to previous SLIME apropos anchor."
  (interactive)
  (let ((p (point)))
    (if (re-search-backward slime-apropos-anchor-regexp nil t)
        (goto-char (match-beginning 0))
        (goto-char p)
        (error "anchor not found"))))
(defvar slime-apropos-minor-mode-map (make-sparse-keymap))
(define-key slime-apropos-minor-mode-map (kbd "RET") 'slime-describe-symbol)
(define-key slime-apropos-minor-mode-map (kbd "l") 'slime-describe-symbol)
(define-key slime-apropos-minor-mode-map (kbd "j") 'slime-apropos-next-anchor)
(define-key slime-apropos-minor-mode-map (kbd "k") 'slime-apropos-prev-anchor)
(define-minor-mode slime-apropos-minor-mode "")
(defadvice slime-show-apropos (after slime-apropos-minor-mode activate)
  ""
  (when (get-buffer "*SLIME Apropos*")
    (with-current-buffer "*SLIME Apropos*" (slime-apropos-minor-mode 1))))

;;; clojure-mode and CIDER (via mepla-stable).
(add-hook 'clojure-mode-hook 'paredit-mode)

;;; CIDER
(require 'cider)
(add-hook 'cider-mode-hook 'flyspell-prog-mode)
(add-hook 'cider-repl-mode-hook 'paredit-mode)
(setq cider-repl-pop-to-buffer-on-connect t)
(defun cider-reset ()
  "Sends (refresh) to the remote CIDER REPL buffer.  Only works
in M-x cider buffers connected to localhost."
  (interactive)
  (set-buffer "*cider-repl 127.0.0.1*")
  (goto-char (point-max))
  (insert "(refresh)")
  (cider-repl-return))
;; Have org-babel use CIDER.
(setq org-babel-clojure-backend 'cider)

;;; kibit
;; https://github.com/jonase/kibit
(require 'compile)
(add-to-list 'compilation-error-regexp-alist-alist
             '(kibit "At \\([^:]+\\):\\([[:digit:]]+\\):" 1 2 nil 0))
(add-to-list 'compilation-error-regexp-alist 'kibit)
(defun kibit ()
  "Run kibit on the current project.  Display the results in a
hyperlinked *compilation* buffer."
  (interactive)
  (compile "lein kibit")
  ;; This will clobber the custom function set above.
  (setq compilation-finish-function '()))
(defun kibit-current-file ()
  "Run kibit on the current file.  Display the results in a
hyperlinked *compilation* buffer."
  (interactive)
  (compile (concat "lein kibit " buffer-file-name)))

;;; rainbow-delimiters.el
;; https://github.com/jlr/rainbow-delimiters
(require 'rainbow-delimiters)
(add-hook 'clojure-mode-hook 'rainbow-delimiters-mode)

;;; ac-cider: In-buffer completion for Clojure projects.
;; https://github.com/clojure-emacs/ac-cider
(require 'ac-cider)
(add-hook 'cider-mode-hook 'ac-flyspell-workaround)
(add-hook 'cider-mode-hook 'ac-cider-setup)
(add-hook 'cider-repl-mode-hook 'ac-cider-setup)
(eval-after-load "auto-complete"
                 '(add-to-list 'ac-modes 'cider-mode))
(defun set-auto-complete-as-completion-at-point-function ()
  (setq completion-at-point-functions '(auto-complete)))
(add-hook 'auto-complete-mode-hook 'set-auto-complete-as-completion-at-point-function)
(add-hook 'cider-mode-hook 'set-auto-complete-as-completion-at-point-function)

(defun bcm-clojure-hook ()
  (auto-complete-mode 1)
  (define-key clojure-mode-map (kbd "<S-tab>") 'auto-complete)
  ;; (define-key cider-mode-map (kbd "C-c C-o") 'cider-reset)
  (define-key clojure-mode-map (kbd "C-w") 'paredit-backward-kill-word))
(add-hook 'clojure-mode-hook 'bcm-clojure-hook)
(add-hook 'cider-repl-mode-hook
          '(lambda ()
            (define-key cider-repl-mode-map
             (kbd "C-w") 'paredit-backward-kill-word)))
;; Fix missing *nrepl-messages* buffer.
(setq nrepl-log-messages 1)

;;; intero: A complete developer environment for Haskell.
;; https://commercialhaskell.github.io/intero/
(add-hook 'haskell-mode-hook 'intero-mode)
;; Enable prettify-symbols-mode symbols-alists in buffers.
(add-hook 'haskell-mode-hook 'bcm-haskell-prettify-enable)
(add-hook 'intero-repl-mode-hook 'bcm-haskell-prettify-enable)

;;; geiser
;; http://www.nongnu.org/geiser/
(load-file "~/.emacs.d/lisp/geiser/elisp/geiser.el")
(setq geiser-default-implementation 'racket)
(setq scheme-program-name "racket")

;;; python-mode: Replaces the built-in python.el, though I'm no longer using
;;; its integrated iPython support.
;; http://launchpad.net/python-mode/
(autoload 'python-mode "python-mode" "Python Mode." t)
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode))
(add-to-list 'interpreter-mode-alist '("python" . python-mode))
;; NOTE: python-describe-symbol requires the python-doc-html package and the
;;       PYTHONDOCS environment variable to be set.  This isn't valid in
;;       python-mode though, only in python.el.
(add-hook 'python-mode-hook
          (lambda ()
            (set (make-variable-buffer-local 'beginning-of-defun-function)
                 'py-beginning-of-def-or-class)
            (setq outline-regexp "def\\|class ")
            (pabbrev-mode)
            (flyspell-prog-mode)
            (flymake-mode)
            (local-set-key (kbd "C-c L") 'py-execute-buffer)))
;; Replaced pylint with pyflakes, as it's super fast.  However, it doesn't
;; catch a lot of style problems, so it's still a good idea to pylint it later.
;; http://www.emacswiki.org/emacs/PythonProgrammingInEmacs#toc9
(defun flymake-pyflakes-init ()
  "Initialize Flymake for Python, using pyflakes."
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name
                      temp-file
                      (file-name-directory buffer-file-name))))
    (list "pyflakes" (list local-file))))
(when (load "flymake" t)
  (push '("\\.py\\'" flymake-pyflakes-init)
        flymake-allowed-file-name-masks))

;;; AUCTeX
;; http://www.gnu.org/software/auctex/
;; FreeBSD ports, Linux apt-get version, OSx brew version.
;; Note: On OSX, install the BasicTeX package, then add its install location to $PATH.
(when (not *nt-system*)
  (load "auctex.el" nil t t)
  (load "preview-latex.el" nil t t)
  (add-hook 'LaTeX-mode-hook 'turn-on-auto-fill)
  (add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
  ;; Enable this when working with multi-file document structures.
  ;; (setq-default TeX-master nil)
  ;; Enable document parsing.
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  ;; Full section options.  See Sectioning page in AUCTeX info.
  (setq LaTeX-section-hook
        '(LaTeX-section-heading
          LaTeX-section-title
          LaTeX-section-toc
          LaTeX-section-section
          LaTeX-section-label)))

;;; web-mode: An autonomous major-mode for editing web templates (HTML
;;; documents embedding parts (CSS/JavaScript) and blocks (client/server side).
;; https://github.com/fxbois/web-mode
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[gj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode))
(setq web-mode-markup-indent-offset 2)
(setq web-mode-css-indent-offset 2)
(setq web-mode-code-indent-offset 2)
(add-hook 'web-mode-hook 'flyspell-mode)

;;; rainbow-mode: Adds color hinting for colors in hex, RBG, and named.
;; https://github.com/emacsmirror/rainbow-mode
(require 'rainbow-mode)
(add-hook 'css-mode-hook (lambda () (rainbow-mode 1)))
(add-hook 'html-mode-hook (lambda () (rainbow-mode 1)))

;;; flymake-cursor
;; http://www.emacswiki.org/emacs/download/flymake-cursor.el
(require 'flymake-cursor)

;;; js2-mode
;; https://github.com/mooz/js2-mode
(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))

;;; json-mode (via melpa-stable).
;; Includes json-reformat and json-snatcher.
;; Note: Use C-c C-f reformats, C-c C-p displays path to object at point.
(add-to-list 'auto-mode-alist '("\\.json\\'" . json-mode))

;;; gnuplot-mode
;; https://raw.github.com/mkmcc/gnuplot-mode/master/gnuplot-mode.el
(require 'gnuplot-mode)
(add-hook 'gnuplot-mode-hook
          '(lambda ()
            (flyspell-prog-mode)
            (add-hook 'before-save-hook
             'whitespace-cleanup nil t)))
;; .gp is my personally-designated Gnuplot extension.
(add-to-list 'auto-mode-alist '("\\.gp$" . gnuplot-mode))

;;; markdown-mode
;; https://github.com/jrblevin/markdown-mode
;; Note: Install textproc/markdown to integrate compilation commands.
(autoload 'markdown-mode "markdown-mode"
          "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;;; Maxima support
(setq auto-mode-alist (cons '("\\.max" . maxima-mode) auto-mode-alist))
(when *freebsd-system*
  (setq load-path (cons "/usr/local/share/maxima/5.38.1/emacs" load-path)))
(when *linux-system*
  (setq load-path (cons "/usr/share/maxima/5.38.1/emacs" load-path)))
(when *nt-system*
  (setq load-path
        (cons "C:\\bin\\utils\\maxima\\share\\maxima\\5.20.1\\emacs"
              load-path)))
(autoload 'maxima "maxima" "Running Maxima interactively" t)
(autoload 'maxima-mode "maxima" "Maxima editing mode" t)

;;; Mutt client integration.
;; This associates file whose name contains "/mutt" to be in mail-mode.
(add-to-list 'auto-mode-alist '("/mutt" . mail-mode))
(add-hook 'mail-mode-hook 'turn-on-auto-fill)
;; Use C-c C-c to complete mutt message buffers without prompting for saving.
(add-hook
 'mail-mode-hook
 (lambda ()
   (define-key mail-mode-map (kbd "C-c C-c")
     (lambda ()
       (interactive)
       (save-buffer)
       (server-edit)))))

;;; gtags
;; Requires an install of GNU Global.  Currently only using for c-mode.
(when *freebsd-system*
  (setq load-path (cons "/usr/local/share/gtags" load-path))
  (autoload 'gtags-mode "gtags" "" t)
  (setq c-mode-hook '(lambda () (gtags-mode 1))))

;;; aggressive-indent-mode: On-the-fly indenting.
;; https://github.com/Malabarba/aggressive-indent-mode
(require 'aggressive-indent)
(global-aggressive-indent-mode 1)
;; Add any modes I want to exclude from this minor mode.
(add-to-list 'aggressive-indent-excluded-modes 'web-mode)
(add-to-list 'aggressive-indent-excluded-modes 'haskell-mode)

;;; elscreen
;; https://github.com/knu/elscreen
(require 'elscreen)
(elscreen-start)
;; F7 creates a new elscreen, F8 kills it.
(global-set-key (kbd "<f7>") 'elscreen-create)
(global-set-key (kbd "<f8>") 'elscreen-kill)

;;; emacs-w3m
;; http://emacs-w3m.namazu.org/
;; FreeBSD: ports w3m-m17n; Linux: apt-get w3m w3m-el; Windows: CVS, Cygwin w3m
;; NOTE: I also modify the local copies of w3m.el and w3m-search.el.  See
;;       projects.org for details.
(autoload 'w3m "w3m" "Interface for w3m on Emacs." t)
;; Use w3m for all URLs (deprecated code to use available GUI browser).
(setq browse-url-browser-function 'w3m-browse-url)
(autoload 'w3m-browse-url "w3m" "Ask a WWW browser to show a URL." t)
;; Optional keyboard short-cut.
(global-set-key (kbd "C-x M-m") 'browse-url-at-point)
;; Tabs: create: C-c C-t close: C-c C-w nav: C-c C-[np] list: C-c C-s
(setq w3m-use-tab t)
(setq w3m-use-cookies t)
;; Activate Conkeror-style link selection (toggle with f key).
(add-hook 'w3m-mode-hook 'w3m-lnum-mode)
;; To use w3m-search, hit S in w3m.  Do a C-u S to specify engine.
(require 'w3m-search)
;; Add some extra search engine URIs.
(add-to-list 'w3m-search-engine-alist
             '("hoogle" "http://haskell.org/hoogle/?q=%s"))
(add-to-list 'w3m-search-engine-alist
             '("ports" "http://freebsd.org/cgi/ports.cgi/?query=%s" nil))
(add-to-list 'w3m-search-engine-alist
             '("wikipedia" "http://en.m.wikipedia.org/wiki/Special:Search?search=%s" nil))
(add-to-list 'w3m-search-engine-alist
             '("duckduckgo" "http://www.duckduckgo.com/?q=%s" nil))
(setq w3m-search-default-engine "duckduckgo")
;; Default to the last manually specified search engine when calling the prefix
;; version of the function.
(defadvice w3m-search (after change-default activate)
  (let ((engine (nth 1 minibuffer-history)))
    (when (assoc engine w3m-search-engine-alist)
      (setq w3m-search-default-engine engine))))

;;; multi-term
;; http://www.emacswiki.org/emacs/download/multi-term.el
(autoload 'multi-term "multi-term" nil t)
(autoload 'multi-term-next "multi-term" nil t)
(when *freebsd-system*
  (setq multi-term-program "/usr/local/bin/zsh"))
(when *linux-system*
  (setq multi-term-program "/usr/bin/zsh"))
(when *nt-system*
  (setq multi-term-program "/usr/bin/bash"))
(when *osx-system*
  (setq multi-term-program "/bin/zsh"))
(global-set-key (kbd "C-c t") 'multi-term-next)
(global-set-key (kbd "C-c T") 'multi-term)

;;; lusty-explorer
;; https://github.com/sjbach/lusty-emacs
(require 'lusty-explorer)
(global-set-key (kbd "C-x C-f") 'lusty-file-explorer)
(global-set-key (kbd "C-x b") 'lusty-buffer-explorer)

;;; EMMS
;; http://www.gnu.org/software/emms/
;; Currently using mplayer backend - seems superior to mpg321, which doesn't
;; support seeking.
(require 'emms-setup)
(emms-standard)
(emms-default-players)
(push 'emms-player-mplayer emms-player-list)
;; Show the current track each time EMMS starts to play a track with "NP: ".
(add-hook 'emms-player-started-hook 'emms-show)
(setq emms-show-format "NP: %s")
;; When asked for emms-play-directory, always start from this one.
(setq emms-source-file-default-directory "~/snd/")
;; Some global playlist management keybindings.
(global-set-key (kbd "<kp-subtract>") 'emms-previous)
(global-set-key (kbd "<kp-add>") 'emms-next)
(global-set-key (kbd "<insert>") 'emms-pause)
(global-set-key (kbd "<kp-insert>") 'emms-pause)
(global-set-key (kbd "<kp-right>") 'emms-seek-forward)
(global-set-key (kbd "<kp-left>") 'emms-seek-backward)

;;; with-editor: Allows use of emacsclient as the $EDITOR of child processes.
;; https://github.com/magit/with-editor
(require 'with-editor)

;;; magit-popup: A switch/option setting interface, used by Magit.
;; https://github.com/magit/magit-popup
(require 'magit-popup)

;;; ghub: An interface for GitHub's REST and GraphQL APIs.  Used by Magit.
;; https://github.com/magit/ghub
(require 'ghub)

;;; Magit: Requires dash (installed via ELPA), with-editor, magit-popup, and
;;; ghub.
;; https://github.com/magit/magit
(require 'magit)
;; Idiomatic fill-column setting for commit messages.
(add-hook 'git-commit-mode-hook
          '(lambda () (set-fill-column 72)))
(global-set-key (kbd "<f3>") 'magit-status)

;;; git-gutter
;; https://github.com/syohex/emacs-git-gutter
(require 'git-gutter)
(global-git-gutter-mode +1)
(global-set-key (kbd "C-x C-g") 'git-gutter:toggle)
(global-set-key (kbd "C-x v =") 'git-gutter:popup-hunk)

;;; org-present.el
;; https://github.com/rlister/org-present
;; Note: Use arrow keys to navigate, C-c C-q to quit.
(autoload 'org-present "org-present" nil t)
;; Reduce the huge upscaling of text.  This amount is more reasonable for my
;; laptop, but reconsider it for larger displays.
(setq org-present-text-scale 2)
(add-hook 'org-present-mode-hook
          (lambda ()
            (org-present-big)
            (org-display-inline-images)))
(add-hook 'org-present-mode-quit-hook
          (lambda ()
            (org-present-small)
            (org-remove-inline-images)))

;;; xterm-color.el: A dependency for wttrin.el.
;; https://github.com/atomontage/xterm-color
(require 'xterm-color)

;;; wttrin.el: Get a weather report.
;; https://github.com/bcbcarl/emacs-wttrin
;; Note: Requires xterm-color.
(require 'wttrin)
(setq wttrin-default-cities '("Fairfax" "Centreville"))
(setq wttrin-default-accept-language '("Accept-Language" . "en-US"))

;;; lojban-mode: Requires lojban.el.
;; http://www.emacswiki.org/cgi-bin/wiki/download/lojban-mode.el
;; http://www.emacswiki.org/emacs/download/lojban.el
(autoload 'lojban-mode "lojban-mode" nil t)
;; To parse regions, ensure the jbofihe binary is on $PATH.
;; https://github.com/lojban/jbofihe
(autoload 'lojban-parse-region "lojban" nil t)

;;; redo+.el: An extended version of XEmacs' redo package.
;; http://www.emacswiki.org/emacs/download/redo%2b.el
;; TODO: Consider replacing this with undo-tree-mode.  I'm sticking with this
;; for now since it's considerably more intuitive and the need for undo-trees
;; hasn't ever yet come up.
(require 'redo+)
(global-set-key (kbd "C-x M-_") 'redo)

;;; htmlize.el: Converts buffer to HTML.
;; https://github.com/hniksic/emacs-htmlize
;; TODO: Check if htmlfontify.el (being added in 23.2) is the same as this.
(require 'htmlize)

;;; powerline.el: Mode line replacement.  Using a fork that fixes some display
;;; issues.
;; https://github.com/milkypostman/powerline.git
(when window-system
  (require 'powerline)
  (powerline-default-theme))

;;; Printing
;; Remap lpr-command to xpp on FreeBSD.  Requires print/xpp port.
(when *freebsd-system*
  (setq lpr-command "xpp"))
;; Requires install of Ghostscript and GSView native ports on Windows.
(when *nt-system*
  (progn
    (setq-default ps-lpr-command
                  (expand-file-name
                   "C:\\bin\\utils\\gs\\gsview\\gsview\\gsprint.exe"))
    (setq-default ps-printer-name t)
    (setq-default ps-printer-name-option nil)
    (setq ps-lpr-switches '("-query"))   ; Show printer dialog.
    (setq ps-right-header
          '("/pagenumberstring load" ps-time-stamp-mon-dd-yyyy))))

;;; diminish.el: mode-line shortening
;; https://www.eskimo.com/~seldon/diminish.el
(when (require 'diminish nil 'noerror)
  (eval-after-load "git-gutter" '(diminish 'git-gutter-mode "Git↓"))
  (eval-after-load "Paredit" '(diminish 'paredit-mode "(ᴩ)")))
;; Non-diminish major mode mode-line shortening.
(add-hook 'haskell-mode-hook
          (lambda () (setq mode-name "λ≫")))
(add-hook 'emacs-lisp-mode-hook
          (lambda () (setq mode-name "e-λ")))
(add-hook 'clojure-mode-hook
          (lambda () (setq mode-name "cλj")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Final init

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(git-gutter:update-interval 2)
 '(haskell-process-auto-import-loaded-modules t)
 '(haskell-process-log t)
 '(haskell-process-suggest-remove-import-lines t)
 '(haskell-process-type (quote cabal-repl))
 '(package-selected-packages
   (quote
    (projectile json-mode intero haskell-mode ac-cider cider clojure-mode)))
 '(safe-local-variable-values (quote ((eldoc-mode . t) (outline-minor-mode . t))))
 '(semantic-complete-inline-analyzer-displayor-class (quote semantic-displayor-tooltip))
 '(semantic-complete-inline-analyzer-idle-displayor-class (quote semantic-displayor-tooltip))
 '(semantic-idle-scheduler-verbose-flag nil)
 '(semantic-imenu-sort-bucket-function (quote semantic-sort-tags-by-name-increasing))
 '(which-function-mode nil))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Replace echo area startup message.
(run-with-timer 1 nil (lambda () (message "I have SEEN the CONSING!!")))
