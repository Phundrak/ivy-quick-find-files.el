;;; ivy-quick-find-files.el --- Quickly find files in directories and by extension -*- lexical-binding: t -*-

;; Author: Lucien Cartier-Tilet <lucien@phundrak.com>
;; Maintainer: Lucien Cartier-Tilet <lucien@phundrak.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "24") (ivy "0.13"))
;; Homepage: https://labs.phundrak.com/phundrak/ivy-quick-find-files.el

;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.


;;; Commentary:

;;; Code:

(require 'ivy)

                                        ; Group ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defgroup ivy-quick-find-files nil
  "Quickly find files by directory and extension."
  :group 'convenience
  :prefix "ivy-quick-find-files-"
  :link '(url-link :tag "Github" "https://github.com/phundrak/ivy-quick-find-files.el")
  :link '(url-link :tag "Gitea" "https://labs.phundrak.com/phundrak/ivy-quick-find-files.el"))

                                        ; Custom variables ;;;;;;;;;;;;;;;;;;;;

(defcustom ivy-quick-find-files-program (if (executable-find "fd")
                                            'fd
                                          'find)
  "Program to find files on your system.

By default, the value is 'fd, but you can change it to 'find too.
For now, no other program is supported.

By default, ivy-quick-find-files will try to find fd or find in your
path.  You can customize the executable to use with
`ivy-quick-find-files-fd-executable' and
`quind-find-files-find-executable'."
  :group 'ivy-quick-find-files
  :type 'symbol)

(defcustom ivy-quick-find-files-fd-executable (executable-find "fd")
  "Executable name or path to the executable of fd."
  :group 'ivy-quick-find-files
  :type 'string)

(defcustom ivy-quick-find-files-find-executable (executable-find "find")
  "Executable name or path to the executable of find."
  :group 'ivy-quick-find-files
  :type 'string)

(defcustom ivy-quick-find-files-dirs-and-exts '()
  "List of pairs of directories and extensions.

Each element should be a pair of a directory path and an
extension, such as

'((\"~/Documents/org/\" . \"org\"))"
  :group 'ivy-quick-find-files
  :type 'list)

(defcustom ivy-quick-find-files-fd-additional-options ""
  "Additional command-line options for fd."
  :group 'ivy-quick-find-files
  :type 'string)

(defcustom ivy-quick-find-files-find-additional-options ""
  "Additional command-line options for find."
  :group 'ivy-quick-find-files
  :type 'string)

                                        ; Internal functions ;;;;;;;;;;;;;;;;;;

(defun ivy-quick-find-files--split-lines (str &optional omit-null)
  "Split a multilines `STR' into a list of strings.

If `OMIT-NULL' is non-null, ignore empty strings."
  (declare (side-effect-free t))
  (split-string str "\\(\r\n\\|[\n\r]\\)" omit-null))

(defun ivy-quick-find-files--find-files (dir ext)
  "Find files in directory DIR with extension EXT.

Use `fd' or `find' depending on `ivy-quick-find-files-program'.
Return files as a list of absolute paths."
  (declare (side-effect-free t))
  (ivy-quick-find-files--split-lines
   (shell-command-to-string (format
                             (pcase ivy-quick-find-files-program
                               ('fd "fd . %s -e %s -c never %s")
                               ('find "find %s -name \"*.%s\" %s")
                               (otherwise (error "Find program %s not implemented" otherwise)))
                             dir
                             ext
                             (pcase ivy-quick-find-files-program
                               ('fd ivy-quick-find-files-fd-additional-options)
                               ('find ivy-quick-find-files-find-additional-options)
                               (otherwise (error "Find program %s not implemented" otherwise)))))))

                                        ; Public functions ;;;;;;;;;;;;;;;;;;;;

;;;###autoload
(defun ivy-quick-find-files-list-files ()
  "List files in directories and with specific extensions.

The directories and extensions are specified in the variable
`ivy-quick-find-files-dirs-and-exts'.

Return a list of paths to files."
  (declare (side-effect-free t))
  (mapcan (lambda (dir-ext)
            (ivy-quick-find-files--find-files (car dir-ext)
                                              (cdr dir-ext)))
          ivy-quick-find-files-dirs-and-exts))

;;;###autoload
(defun ivy-quick-find-files ()
  "Quickly find and open files in directories with specific extensions.

Directories in which to look for files with specific extensions
are specified in `ivy-quick-find-files-dirs-and-exts'."
  (interactive)
  (find-file (ivy-completing-read "Open file: "
                                  (ivy-quick-find-files-list-files))))

                                        ; Provides ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide 'ivy-quick-find-files)

;;; ivy-quick-find-files.el ends here
