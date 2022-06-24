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

  def rebuild_tree(array)
    array = merge_sort(array.uniq)
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
    data = level_order

    if data.include? value then
      puts "#{value} already in tree"
    else
      data.push(value)
      self.rebuild_tree(data)
    end
  end

  def delete(value)
    data = level_order

    if data.include? value
      data -= [value]
      self.rebuild_tree(data)
    else
      puts "#{value} not in tree"
    end

  end

  def find(value, node = @root)
    return node if value == node.data

    if value < node.data then
      node.left ? better_find(value, node.left) : return
    else
      node.right ? better_find(value, node.right) : return
    end
  end 

end