# <img src='Workflow/icon.png' width='45' align='center' alt='icon'> Screenshots Alfred Workflow

Search and act on screenshots

[⤓ Install on the Alfred Gallery](https://alfred.app/workflows/vitor/screenshots)

## Usage

### Files

Search screenshots via the `screenshots` keyword.

![Starting screenshots search](Workflow/images/about/filekeyword.png)

![Showing file screenshots grid](Workflow/images/about/filegrid.png)

* <kbd>↩</kbd> View in Alfred.
* <kbd>⌘</kbd><kbd>↩</kbd> Copy to clipboard.
* <kbd>⌥</kbd><kbd>↩</kbd> Reveal in Finder.
* <kbd>⌃</kbd><kbd>↩</kbd> Rerun search with Optical Character Recognition on images.
* <kbd>⇧</kbd><kbd>↩</kbd> Upload to [Imgur](https://imgur.com).

![Showing single image](Workflow/images/about/imagepreview.png)

* <kbd>↩</kbd> Show compatible apps for opening.
* <kbd>⌘</kbd><kbd>↩</kbd> Copy to clipboard.
* <kbd>⌥</kbd><kbd>↩</kbd> Reveal in Finder.
* <kbd>⇧</kbd><kbd>↩</kbd> Upload to [Imgur](https://imgur.com).
* <kbd>⎋</kbd> Return to Grid View.

### Clipboard

View clipboard images via the `clipimg` keyword. The same actions as searching files apply.

![Keyword to view clipboard images](Workflow/images/about/clipkeyword.png)

![Showing clipboard screenshots grid](Workflow/images/about/clipgrid.png)

### Web

Take an interactive screenshot and upload it to Imgur via the `imgur` keyword. This requires [getting an API client ID](https://api.imgur.com/oauth2/addclient) and adding it in the [Workflow’s Configuration](https://www.alfredapp.com/help/workflows/user-configuration/).

![Take screenshot to imgur](Workflow/images/about/imgurkeyword.png)

Alternatively, upload any image with the [Universal Action](https://www.alfredapp.com/help/features/universal-actions/).

![Upload to Imgur with Universal Action](Workflow/images/about/imgurua.png)

View uploaded images with <kbd>⌥</kbd><kbd>↩</kbd> in the `imgur` keyword.

![Viewing uploaded images](Workflow/images/about/imguruploaded.png)

* <kbd>↩</kbd> View in Alfred.
* <kbd>⌘</kbd><kbd>↩</kbd> Delete from Imgur.
* <kbd>⌥</kbd><kbd>↩</kbd> Copy image URL.
