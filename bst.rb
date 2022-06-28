class Node
  attr_accessor :data, :left, :right

  def initialize(value)
    self.data = value
    self.left = nil
    self.right = nil
  end

  def add_child(value)
    return if value == nil
    value.instance_of?(Node) ? child = value : child = Node.new(value)

    if self.data == child.data then
      puts "Discarding duplicate value #{child.data}"
      return
    end

   if child.data < self.data then
    self.left == nil ? self.left = child : self.left.add_child(child)
   else
    self.right == nil ? self.right = child : self.right.add_child(child)
   end
  end

end

class Tree
  attr_reader :root

  def initialize(data_array)
    #remove duplicates and sort data
    sorted_array = merge_sort(data_array.uniq)
    #create the tree
    @root = self.build_tree(sorted_array)
  end

  def build_tree(data_array)
    return if data_array.empty?

    root = Node.new(data_array[data_array.length/2])
    root.add_child( build_tree(data_array[0...data_array.length/2]) )
    root.add_child( build_tree(data_array[data_array.length/2 + 1..-1]) )

    root
  end

  def rebalance(data_array = self.inorder)
    array = merge_sort(data_array)
    @root = build_tree(array)
  end

  def merge_sort(data_array)
    return data_array if data_array.length < 2

    left = merge_sort(data_array[0...data_array.length/2])
    right = merge_sort(data_array[data_array.length/2..-1])

    result = []
    until left.empty? || right.empty?
      left[0] < right[0] ? result.push(left.shift) : result.push(right.shift)
    end

    result = result + left + right
    result
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end

  def level_order(queue = [@root], accumulator = [], &block)
    #pull next node from queue
    node = queue.shift

    #add children to back of queue
    queue.push(node.left) unless node.left == nil
    queue.push(node.right) unless node.right == nil

    if block_given?
      #yield current node to passed block
      block.call(node)
      #continue through the queue until we reach the end
      queue.empty? ? return : (level_order(queue, accumulator, &block))
    else
      #add current node's data to array so we can return it
      accumulator.push(node.data)
      #continue through the queue until we reach the end
      queue.empty? ? accumulator : level_order(queue, accumulator)
    end

  end

  def insert(value)
    #TODO: Find a better way
    # For this and #delete, you can probably just build a smaller tree
    # with the root node being the new node taking its place
    # ...but then we have to rebalance if >1 node is inserted/removed
    data = level_order

    if data.include? value then
      puts "#{value} already in tree"
    else
      data.push(value)
      self.rebalance(data)
    end
  end

  def better_insert(value)
    #find closest node to value
    closest_node = @root
    closest_diff = (value - closest_node.data).abs
    closest_parent = @root

    node = @root
    parent_node = nil
    until !node.left && !node.right do
      current_diff = (value - node.data).abs

      # save closer node if difference is smaller
      if current_diff <= closest_diff then
        closest_diff = current_diff
        closest_node = node
        closest_parent = parent_node
      end

      # move left or right based on value
      if value > node.data then
        if node.right then
          parent_node = node
          node = node.right 
        else 
          break
        end
      else
        if node.left then
          parent_node = node
          node = node.left
        else 
          break
        end
      end
    end

    #return if value is a duplicate
    return if closest_diff == 0

    # use self.level_order(node) to get sorted array of that subtree
    # and add them as children to our new node in the correct order to
    # keep it balanced
    new_node = Node.new(value)
    subtree_data = self.level_order([closest_node])
    subtree_data.each { |value| new_node.add_child(value) }


    # place our new node in tree in tree
    if @root == closest_node then
      @root = new_node # we just rebuilt the whole tree
    else
      # attach new_node to left or right of parent, depending on its value
      new_node.data > closest_parent.data ? closest_parent.right = new_node : closest_parent.left = new_node
    end

    # make sure the tree is still balanced
    unless self.balanced?
      puts "Rebalancing..."
      self.rebalance
    end

  end

  def delete(value)
    #TODO: Find a better way
    data = level_order

    if data.include? value then
      data -= [value]
      self.rebalance(data)
    else
      puts "#{value} not in tree"
    end
  end

  def find(value, node = @root)
    return node if value == node.data

    if value < node.data then
      node.left ? find(value, node.left) : return
    else
      node.right ? find(value, node.right) : return
    end

  end 

  def inorder(node = @root, accumulator = [], &block)
    # inorder = DFS left, parent, right

      if node.left then
        block_given? ? inorder(node.left, [], &block) : accumulator = inorder(node.left, accumulator)
      end

      block_given? ? block.call(node) : accumulator.push(node.data)
      
      if node.right then
        block_given? ? inorder(node.right, [], &block) : accumulator = inorder(node.right, accumulator)
      end

      accumulator unless block_given?
  end

  def preorder(node = @root, accumulator = [], &block)
    # preorder = DFS parent, left, right

    block_given? ? block.call(node) : accumulator.push(node.data)

    if node.left then
      block_given? ? preorder(node.left, [], &block) : accumulator = preorder(node.left, accumulator)
    end

    if node.right then
      block_given? ? preorder(node.right, [], &block) : accumulator = preorder(node.right, accumulator)
    end

    accumulator unless block_given?
  end

  def postorder(node = @root, accumulator = [], &block)
    # postorder = DFS left, right, parent

    if node.left then
      block_given? ? postorder(node.left, [], &block) : accumulator = postorder(node.left, accumulator)
    end

    if node.right then
      block_given? ? postorder(node.right, [], &block) : accumulator = postorder(node.right, accumulator)
    end

    block_given? ? block.call(node) : accumulator.push(node.data)

    accumulator unless block_given?
  end

  def height(node = @root, height = 0)
    # returns height of tree if no node given
    # return value if we've reached a leaf node
    return height unless node.left || node.right
    
    # check height of left and right trees
    left_height, right_height = 0, 0
    left_height = height(node.left, height + 1) if node.left
    right_height = height(node.right, height + 1) if node.right

    # return whichever is greater
    left_height > right_height ? left_height : right_height
  end

  def depth(target, node = @root, depth = 0)
    #base case - return current depth if we've reached target node
    return depth if node == target

    # binary search for the end
    if target.data < node.data then
      node.left ? depth = depth(target, node.left, depth + 1) : return
    else
      node.right ? depth = depth(target, node.right, depth + 1) : return
    end

    depth
  end

  def balanced?
    return 1 >= ( height(@root.left) - height(@root.right) ).abs
  end

end