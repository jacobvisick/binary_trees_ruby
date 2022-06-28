# From Project Odin:
# Write a simple driver script that does the following:
require './bst.rb'

# - Create a binary search tree from an array of random numbers (Array.new(15) { rand(1..100) })
bst = Tree.new(Array.new(15) { rand(1..100) })
bst.pretty_print

# - Confirm that the tree is balanced by calling #balanced?
puts "Tree is balanced? #{bst.balanced?}"

# - Print out all elements in level, pre, post, and in order
puts "Level Order: #{bst.level_order}"
puts "Preorder: #{bst.preorder}"
puts "Postorder: #{bst.postorder}"
puts "Inorder: #{bst.inorder}"

# - Unbalance the tree by adding several numbers > 100
puts "Unbalancing..."
bst.insert(101)
bst.insert(102)
bst.insert(103)
bst.insert(104)

# - Confirm that the tree is unbalanced by calling #balanced?
puts "Is tree balanced? #{bst.balanced?}"
puts "(Should be true, since we rebalance in #insert)"

# - Balance the tree by calling #rebalance
puts "Rebalancing..."
bst.rebalance

# - Confirm that the tree is balanced by calling #balanced?
puts "Is tree balanced? #{bst.balanced?}"

# - Print out all elements in level, pre, post, and in order
puts "Level Order: #{bst.level_order}"
puts "Preorder: #{bst.preorder}"
puts "Postorder: #{bst.postorder}"
puts "Inorder: #{bst.inorder}"
bst.pretty_print