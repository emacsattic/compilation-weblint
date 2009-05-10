;;; compilation-weblint.el --- error regexps for weblint

;; Copyright 2007, 2008 Kevin Ryde

;; Author: Kevin Ryde <user42@zip.com.au>
;; Version: 2
;; Keywords: processes
;; URL: http://www.geocities.com/user42_kevin/compilation/index.html
;; EmacsWiki: CompilationMode

;; compilation-weblint.el is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; compilation-weblint.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
;; Public License for more details.
;;
;; You can get a copy of the GNU General Public License online at
;; <http://www.gnu.org/licenses>.


;;; Commentary:

;; This spot of code adds a `compilation-error-regexp-alist' pattern for
;; messages from the weblint program (the one based on the perl HTML::Lint
;; modules).

;;; Install:

;; Put compilation-weblint.el somewhere in your `load-path', and in .emacs put
;;
;;     (eval-after-load "compile" '(require 'compilation-weblint))
;;
;; There's an autoload cookie below for this, if you know how to use
;; `update-file-autoloads' and friends.

;;; Emacsen:

;; Designed for Emacs 21 and 22, works in XEmacs 21.

;;; History:

;; Version 1 - the first version
;; Version 2 - put the eval-after-load in .emacs


;;; Code:

;;;###autoload (eval-after-load "compile" '(require 'compilation-weblint))

(require 'compile)

;; The messages come from HTML::Lint::Error::as_string(), eg.
;;
;;     index.html (13:1) Unknown element <fdjsk>
;;
;; The pattern only matches filenames without spaces, since that should
;; be usual and should help reduce the chance of a false match of a
;; message from some unrelated program.
;;
;; This message style is quite close to the "ibm" entry of emacs22
;; `compilation-error-regexp-alist-alist' which is for IBM C, but that ibm
;; one doesn't have a space after the filename.
;;
(let ((elem '(compilation-weblint
              "^\\([^ \t\r\n(]+\\) (\\([0-9]+\\):\\([0-9]+\\)) "
              1 2 3)))

  (cond ((boundp 'compilation-error-regexp-systems-list)
         ;; xemacs21
         (add-to-list 'compilation-error-regexp-alist-alist
                      (list (car elem) (cdr elem)))
         (compilation-build-compilation-error-regexp-alist))

        ((boundp 'compilation-error-regexp-alist-alist)
         ;; emacs22
         (add-to-list 'compilation-error-regexp-alist-alist elem)
         (add-to-list 'compilation-error-regexp-alist (car elem)))

        (t
         ;; emacs21
         (add-to-list 'compilation-error-regexp-alist (cdr elem))

         ;; Remove the "4.3BSD lint pass 3" element because it wrongly
         ;; matches weblint messages.  It's apparently supposed to match
         ;; something like
         ;;
         ;;     bloofle defined( /users/wolfgang/foo.c(4) ) ...
         ;;
         ;; but it's rather loose and ends up matching the "(13:1)" part
         ;; from weblint (see above) as if "13" is the filename and "1" is
         ;; the line number.  Forcibly removing is pretty nasty, but emacs22
         ;; has dropped it, so consider this an upgrade!
         ;;
         ;; xemacs21 has the same pattern, but somehow the problem
         ;; doesn't arise, so leave it alone there, for now.
         ;;
         (setq compilation-error-regexp-alist
               (remove '(".*([ \t]*\\([a-zA-Z]?:?[^:( \t\n]+\\)[:(][ \t]*\\([0-9]+\\))" 1 2)
                       compilation-error-regexp-alist)))))

(provide 'compilation-weblint)

;;; compilation-weblint.el ends here
