## digger v0.1: nonlinear tracker

a sequencer built for flexibility and branching structures

### glossary
|term|description|
|-|-|
| **root** | the first node, which every other node branches from. 
| **parent** | a node with children. 
| **children** | nodes contained by a parent node.
| **leaf** | a node with no children.

### requirements
* HID keyboard

### keyboard mappings
| key | function |
|-|-|
| `arrows/HJKL` | **navigate** up, down and across the tree. When holding shift, select nodes.
| `space bar` | **play/pause** sequence
| `R` | **reset** sequence
| `enter/return` | **select** single node. When typing, finalize text buffer.
| `backspace/delete` | **delete** node/s
| `escape` | back, cancel, **exit**, deselect, etc.
| `1, 2, 3, 4, 5...` | select node **attribute** to edit, or select from on-screen options.
| `Q/W` | **increment/decrement** currently selected attribute
| `X` | **cut** selected nodes to clipboard
| `C` | **copy** selected nodes to clipboard
| `V` | **paste** from clipboard
| `B` | **bundle** selected nodes into a new parent

**Math functions** affect the currently selected attribute. When you press any of these keys, you will be prompted to enter a number. Press enter, and your change will be immediately applied to all selected nodes.
| key | function |
|-|-|
| `=` | set attribute to n
| `+` | add n to attribute
| `-` | subtract n from attribute
| `*` | multiply attribute by n
| `/` | divide attribute by n
| `?` | randomize attribute by +/- n

### overview and structure
Like an old-school tracker, digger manages a sequence of events. Instead of a tracker's linear list, digger is structured as an [arbitrary tree](https://en.wikipedia.org/wiki/Tree_traversal#Arbitrary_trees).

In digger, there is only one type of data, called a node. Nodes can have between 0 and 127 "children". 

When a node is reached, if it has 0 children, it is played as a note, sending the data it contains out to [n.b.](https://llllllll.co/t/n-b-et-al-v0-1/60374) to be processed as midi, voltage or sound.

Otherwise, if the node *does* have children, each of those children is played as note in order. But if any of the children are *themselves also parents*, all of *their* children are played before releasing to the next node - etc, etc, to infinity and beyond.

Nodes carry a few pieces of data - pitch, velocity and modulation for when they're processed as notes, and an array of children for when they're processed as parents. Less common is the *duration* parameter, which sets the amount of time the node holds focus for before releasing to continue the sequence.

While they're technically the same, think of it this way: for a leaf, duration sets the number of clock ticks that pass before focus is released. For a parent, duration sets the number of times the playhead passes over all of its children before releasing.

Through this functionality, complex structures are available. Each node can be any size musical unit - a single note, an arcade trill, an arpeggio, a short phrase, a pattern, a verse, a song, or even a full set. In order to keep this flexibility managable and performable, tree navigation is fluid. Functions like cut, copy, paste and select all are implemented.