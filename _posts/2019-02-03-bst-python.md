---
layout: post
title: Binary Search Trees in Python
date: 2019-02-03
categories:
---

_This post describes Binary Search Trees and includes a simple python implementation, which is available on [github](https://gist.github.com/nurakawa/e75541b9ccdc5ff4b0c2081336fec19b)._
<br>

 

A ___tree___ is a data structure that is defined as: <br>
empty, or <br> a node with (1) a key and (2) a list of child trees. <br> 

A ___binary search tree___ is a tree where each node has a key that is <br>
(1) larger than the keys of all child nodes in its left subtree and <br>
(2) smaller than the keys of all child nodes in its right subtree. 


### Why use Binary Search Trees?

* To insert, delete, or search for a key costs O(log(N)), where N is the number of nodes in the tree. This is extremely important when N is large

* Binary Search Trees keep data in sorted order, making it possible to implement order statistics (Nth largest or smallest element).

* Binary search trees are Node-based, making them flexible for dynamic data

## Implementation in Python

Below is a Python implementation of a Binary Search Tree. Each `Node` object is initialized with a key (if the key is `None` then the Node is empty) and contains a list of its children. The `BST` object has methods for inserting and finding a Node, as well as for finding its height and size. I also include methods for tree traversal.

```python

# based on: https://gist.github.com/jakemmarsh/8273963

# definition: a tree is either empty or a node with 
# (1) a key and value (2) a list of child trees.


class Node:
	def __init__(self, key):
		self.key = key
		self.left = None
		self.right = None

	def list_of_children(self): 
		children = ()
		if self.left is not None:
			children += (self.left,)
		if self.right is not None:
			children += (self.right,)
		return children


class BST(Node):

	def __init__(self):
		self.root = None

	def insert(self, key):
		if self.root is None:
			self.root = Node(key)
		else:
			self.add_node(self.root, key)

	def add_node(self, current_node, key):
		if key <= current_node.key:
			if current_node.left is not None:
				self.add_node(current_node.left, key)
			else:
				current_node.left = Node(key)
		else:
			if current_node.right is not None:
				self.add_node(current_node.right, key)
			else:
				current_node.right = Node(key)

	def find(self, val):
		return self.find_node(self.root, key)

	def find_node(self, current_node, key):
		if current_node is None:
			return False
		elif key == current_node.key:
			return True
		elif key <= current_node.key:
			return find_node(current_node.left, key)
		elif key > current_node.key:
			return find_node(current_node.right, key)

```

### Height and Size

The _height_ of a tree is the maximum depth of subtree node and farthest left.
The _size_ of a tree is the total number of nodes in the tree, including the root. 

Here I implement them as methods of class BST:


```python

	def height(self):
		return self.find_height(self.root)

	def find_height(self, current_node):
		if current_node is None:
			return 0
		return (1 + max( self.find_height(current_node.left), 
		self.find_height(current_node.right) ))

	def size(self):
		return self.find_size(self.root)

	def find_size(self, current_node):
		if current_node is None:
			return 0
		return (1 + self.find_size(current_node.left) + 
		self.find_size(current_node.right))
```

## Tree Traversal

To traverse through a tree there are two options: <br>

_Depth-first_: We completely traverse one sub-tree before exploring a sibling sub-tree

_Breadth-first_: We traverse all nodes on one level before progressing to next level


### Methods for Depth-first search


`InOrderTraversal` prints each node of a Binary Search Tree in order.<br>
`PreOrderTraversal` traverses the left sub-tree and the right sub-tree, printing root of each tree first.<br>
`PostOrderTraversal` traverses the left sub-tree of the root node, and then the right sub-tree of the root node, printing the root of a tree last.

```python


	def InOrderTraversal(self):
		return self.helper_InOrder(self.root)
	
	def helper_InOrder(self, current_node):
		if current_node is None:
			return
		else:
			self.helper_InOrder(current_node.left)
			print(current_node.key)
			self.helper_InOrder(current_node.right)


	def PreOrderTraversal(self):
		return self.helper_PreOrder(self.root)

	def helper_PreOrder(self, current_node):
		if current_node is None:
			return
		else:
			print(current_node.key)
			if current_node.left is not None:
				self.helper_PreOrder(current_node.left)
			if current_node.right is not None:
				self.helper_PreOrder(current_node.right)

	def PostOrderTraversal(self):
		return self.helper_PostOrder(self.root)

	def helper_PostOrder(self, current_node):
		if current_node is None:
			return
		else:
			if current_node.left is not None:
				self.helper_PostOrder(current_node.left)
			if current_node.right is not None:
				self.helper_PostOrder(current_node.right)
			print(current_node.key)
```	

### Breadth-first search

A breadth-first search traverses all nodes of one _level_ before progressing to the next level. This is implemented as the method `LevelTraversal`, which relies on a queue to print the values.

The following Queue is implemented using the same class `Node` that we use for the Binary Search Tree. A Node's attribute `right` is equivalent to a "next" pointer:

```python

class Queue:

	def __init__(self):
		self.head = None
		self.tail = None
		self.size = 0

	def is_empty(self):
		return self.head is None

	def add_head(self, head):
		self.head = Node(head)
		self.tail = self.head
		self.size += 1

	def enqueue(self, key):
		if self.head is None:
			return self.add_head(key)
		else:
			new_tail = Node(key)			
			self.tail.right = new_tail
			self.tail = new_tail
			self.size += 1

	def dequeue(self):
		if self.head is None:
			self.tail = No
			return
		else:
			ret_val = self.head.key
			new_head = self.head.right
			self.head = new_head
			self.size -= 1
			return(ret_val)
```

#### LevelTraversal 

Below is the method for LevelTraversal (method of class `BST`) which uses a queue:


```python

	# Breadth-first search
	
	def LevelTraversal(self):
		return self.helper_LevelTraversal(self.root)


	def helper_LevelTraversal(self, current_node, q = Queue()):
		if current_node.key is None:
			return
		else:
			q.enqueue(current_node)
		while q.is_empty() == False:
			node = q.dequeue()
			print(node.key)
			if node.left is not None:
				q.enqueue(node.left)
			if node.right is not None:
				q.enqueue(node.right)

```


## References

Sedgewick, R. and Wayne, K. _Algorithms, Fourth Edition_. Accessed 02/03/19. https://algs4.cs.princeton.edu/32bst/

Coursera Data Structures. https://www.coursera.org/learn/data-structures/home/info

Marsh, Jake. https://gist.github.com/jakemmarsh/8273963

Carnegie Mellon University. _Binary Trees_. https://www.cs.cmu.edu/~adamchik/15-121/lectures/Trees/trees.html









