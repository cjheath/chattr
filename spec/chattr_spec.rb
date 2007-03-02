require "chattr"

context "Member element of Array of a specified type" do
    setup do
	@int_array_class = Array(Integer)
	@a = @int_array_class.new
	@r = nil
    end

    # Member assignment:
    specify "should allow that type to be assigned" do
	lambda{@r = (@a[0] = 2)}.should_not raise_error
	@r.should == 2
    end

    specify "should error when other type is assigned to a member" do
	@a << 1
	lambda{@a[0] << "foo"}.should raise_error(TypeError)
    end

    specify "should contain only the value assigned" do
	@r = (@a[0] = 2)
	@a[0].should == 2
	@a.size.should == 1
	@r.should == 2
    end

    specify "should allow that type to be appended" do
	lambda{@r = (@a << 4)}.should_not raise_error
	@r.should == [4]
    end

    specify "should return nil on a positive out-of-bounds index" do
	@r = (@a << 1)
	@a[4].should == nil
	@r.should == [1]
    end

    specify "should return nil on a negative out-of-bounds index" do
	@r = (@a << 1)
	@a[-5].should == nil
	@r.should == [1]
    end

    specify "should replace() the value correctly" do
	@a.concat [1, 2]
	@r = (@a.replace [6, 7, 8])
	@a[0].should == 6
	@a[1].should == 7
	@a[2].should == 8
	@a[3].should == nil
	@a.size.should == 3
	@r.should == [6, 7, 8]
    end

    specify "should throw error when replace breaks the constraints" do
	@a.concat [1, 2]
	lambda{ @a.replace [6, "oops", 8] }.should raise_error
	@a.should == [1, 2]
    end
end

context "Appending and inserting to Array of a specified type" do
    setup do
	@int_array_class = Array(Integer)
	@a = @int_array_class.new
    end

    specify "should contain only the value appended" do
	@a << 5
	@a[0].should == 5
	@a.size.should == 1
    end

    specify "should return the value appended" do
	@a << 6
	@a << 7
	@a[0].should == 6
	@a[1].should == 7
	@a[-1].should == 7
	@a[-2].should == 6
    end

    specify "should error when other type is appended" do
	lambda{@a << "foo"}.should raise_error
    end

    specify "should allow a normal array of that type to be concatenated" do
	@a << 1
	lambda{@a.concat([2, 3])}.should_not raise_error
	@a[0].should == 1
	@a[1].should == 2
	@a[2].should == 3
	@a.size.should == 3
    end

    specify "should allow a matching checked array to be concatenated" do
	@a << 7
	@addend = @int_array_class.new
	@addend << 8
	@addend << 9
	lambda{@a.concat(@addend)}.should_not raise_error
	@a[0].should == 7
	@a[1].should == 8
	@a[2].should == 9
	@a.size.should == 3
    end

    specify "should return values from the concatenated array" do
	@a << 1
	@o = [2]
	@a.concat @o
	@a[0].should == 1
	@a[1].should == 2
	@a[2].should == nil
	@a.size.should == 2
    end

    specify "should error when a normal array containing another type is concatenated" do
	lambda{@a.concat([1, "foo"])}.should raise_error
    end

    specify "should include any values inserted" do
	@a << 6
	@a << 7
	@a.insert(1, 2, 3)
	@a[0].should == 6
	@a[1].should == 2
	@a[2].should == 3
	@a[3].should == 7
	@a[4].should == nil
	@a.size.should == 4
    end

    specify "should error when other type is inserted" do
	@a << 6
	@a << 7
	lambda{@a.insert(1, "foo")}.should raise_error
    end
end

context "When using fill() with an Array of a specified type" do
    setup do
	@int_array_class = Array(Integer)
	@a = @int_array_class.new
    end

    specify "should error when filled with an invalid value" do
	@a.concat([1, 2, 3])
	lambda { @a.fill("oops") }.should raise_error
    end

    specify "should error when filled with an invalid value from a block" do
	@a.concat([1, 2, 3])
	lambda { @a.fill() {|i| "oops"} }.should raise_error
    end

    specify "should be able to be filled with a valid value" do
	@a.concat([1, 2, 3])
	@a.fill(5)
	@a[0].should == 5
	@a[1].should == 5
	@a[2].should == 5
	@a[3].should == nil
    end

    specify "should be able to be filled from given offset with a valid value" do
	@a.concat([1, 2, 3, 4])
	@a.fill(5, 2)
	@a[0].should == 1
	@a[1].should == 2
	@a[2].should == 5
	@a[3].should == 5
	@a[4].should == nil
    end

    specify "should be able to be range-filled with a valid value" do
	@a.concat([1, 2, 3, 4, 5])
	@a.fill(17, (2..3))
	@a[0].should == 1
	@a[1].should == 2
	@a[2].should == 17
	@a[3].should == 17
	@a[4].should == 5
	@a[5].should == nil
    end

    specify "should be able to be filled with a valid value using a block" do
	@a.concat([1, 2, 3])
	@a.fill() {|i| i+30 }
	@a[0].should == 30
	@a[1].should == 31
	@a[2].should == 32
	@a[3].should == nil
    end

    specify "should be able to be filled from given offset with a valid value using a block" do
	@a.concat([1, 2, 3, 4])
	@a.fill(2) {|i| i+30 }
	@a[0].should == 1
	@a[1].should == 2
	@a[2].should == 32
	@a[3].should == 33
	@a[4].should == nil
    end

    specify "should be able to be range-filled with a valid value using a block" do
	@a.concat([1, 2, 3, 4, 5])
	@a.fill(2..3) {|i| i+30 }
	@a[0].should == 1
	@a[1].should == 2
	@a[2].should == 32
	@a[3].should == 33
	@a[4].should == 5
	@a[5].should == nil
    end
end

context "When flatten()ing an Array of a specified type" do
    setup do
	@array_class = Array {|e|
		# Any members must be arrays or be < 10
		Array === e || e < 10
	    }
	@a = @array_class.new
    end

    specify "should flatten like base Arrays" do
	@a.concat [1, [2, 3], 4, [5, 6, 7] ]
	@a.flatten!
	(0...7).each{|i|
	    @a[i].should == i+1
	}
    end

    specify "should throw error when flattening breaks the constraints" do
	@a.concat [1, [2, 3], 4, [5, [10], 7] ]
	lambda { @a.flatten!() }.should raise_error
	@a.should == [1, [2, 3], 4, [5, [10], 7] ]
    end

end

context "When using reflexive collect and map with Array" do
    setup do
	@int_array_class = Array(Integer)
	@a = @int_array_class.new
    end

    specify "should work as long as constraints not broken" do
	@a.concat([1, 2, 3])
	@a.collect!{|i| i*3}

	(0..2).each{|i|
	    @a[i].should == i*3+3
	}
	@a[3].should == nil
	@a.size.should == 3
    end

    specify "should throw error when map! breaks the constraints" do
	@a.concat([1, 2, 3, 4, 5])
	lambda{ @a.map!{|i| i.to_s} }.should raise_error
    end

end

context "Member element of Array having a check block" do
    setup do
	@array_class = Array {|e|
		Integer === e && e < 10 || String === e && e.size < 4
	    }
	@a = @array_class.new
    end

    specify "should allow valid values to be assigned" do
	lambda{@a[0] = 1}.should_not raise_error
	lambda{@a[1] = "foo"}.should_not raise_error
	@a[0].should == 1
	@a[1].should == "foo"
	@a[2].should == nil
	@a.size.should == 2
    end

    specify "should error when invalid values are assigned" do
	lambda{@a[0] = 10}.should raise_error
	lambda{@a[1] = "foobar"}.should raise_error

	@a.size.should == 0
    end

end

context "Member element of Array having a type and a check block" do
    setup do
	@array_class = Array String do |e|
		e.size < 4
	    end
	@a = @array_class.new
    end

    specify "should allow valid values to be assigned" do
	lambda{@a[1] = "foo"}.should_not raise_error
	@a[0].should == nil
	@a[1].should == "foo"
	@a[2].should == nil
	@a.size.should == 2
    end

    specify "should error when invalid values are assigned" do
	lambda{@a[0] = 1}.should raise_error
	lambda{@a[1] = "foobar"}.should raise_error

	@a.size.should == 0
    end

end

context "Checked attribute" do
    setup do
	# Variables: Class, nil, default, block
	my_class = Class.new do
	    typed_attr :not_nil
	    typed_attr nil, :unchecked
	    typed_attr Integer, :int
	    typed_attr Integer, nil, :int_nil
	    typed_attr(:block_checked) { |e|
		    String === e && e.size < 4
		}
	    typed_attr Integer, :block_checked_int do |e|
		    e < 10
		end

	    typed_attr 14, :not_nil_def
	    typed_attr 15, nil, :unchecked_def
	    typed_attr Integer, 16, :int_def
	    typed_attr Integer, 17, nil, :int_nil_def
	    typed_attr("bar", :block_checked_def) { |e|
		    String === e && e.size < 4
		}
	    typed_attr Integer, 8, :block_checked_int_def do |e|
		    e < 10
		end
	end
	@o = my_class.new

	# Assign default to non-nil attributes:
	@o.not_nil = "non-nil"
	@o.int = -1
	@o.block_checked = "asd"
	@o.block_checked_int = 2
    end

    specify "should allow assignment to attributes of all forms" do
	@o.not_nil = ""
	@o.not_nil.should == ""

	lambda{
		@o.unchecked = 200
		@o.unchecked = "A long string"
	    }.should_not raise_error
	@o.unchecked.should == "A long string"

	@o.int = 1
	@o.int.should == 1

	@o.int_nil = 2
	@o.int_nil.should == 2

	@o.int_nil = nil
	@o.int_nil.should == nil

	@o.block_checked = "foo"
	@o.block_checked.should == "foo"

	@o.block_checked_int = 7
	@o.block_checked_int.should == 7
    end

    specify "should allow assignment to defaulted attributes of all forms" do
	@o.not_nil_def.should == 14
	@o.not_nil_def = 24
	@o.not_nil_def.should == 24

	@o.unchecked_def.should == 15
	@o.unchecked_def = 25
	@o.unchecked_def.should == 25

	@o.int_def.should == 16
	@o.int_def = 26
	@o.int_def.should == 26

	@o.int_nil_def.should == 17
	@o.int_nil_def = 27
	@o.int_nil_def.should == 27

	@o.block_checked_def.should == "bar"
	@o.block_checked_def = "foo"
	@o.block_checked_def.should == "foo"

	@o.block_checked_int_def.should == 8
	@o.block_checked_int_def = 2
	@o.block_checked_int_def.should == 2
    end

    specify "should error and leave value unchanged when assigned invalid values" do

	lambda{@o.not_nil = nil}.should raise_error
	@o.not_nil.should_not == nil

	lambda{@o.int = "foo"}.should raise_error
	@o.int.should_not == "foo"

	lambda{@o.int_nil = "foo"}.should raise_error
	@o.int_nil.should_not == "foo"

	lambda{@o.int_nil = "foo"}.should raise_error
	@o.int_nil.should_not == "foo"

	lambda{@o.block_checked = "foobar"}.should raise_error
	@o.block_checked.should_not == "foobar"

	lambda{@o.block_checked = nil}.should raise_error
	@o.block_checked.should_not == nil

	lambda{@o.block_checked_int = 20}.should raise_error
	@o.block_checked_int.should_not == 20

	lambda{@o.block_checked_int = nil}.should raise_error
	@o.block_checked_int.should_not == nil

	lambda{@o.not_nil_def = nil}.should raise_error
	@o.not_nil_def.should_not == nil

	lambda{@o.int_def = "foo"}.should raise_error
	@o.int_def.should_not == "foo"

	lambda{@o.int_nil_def = "foo"}.should raise_error
	@o.int_nil_def.should_not == "foo"

	lambda{@o.int_nil_def = "foo"}.should raise_error
	@o.int_nil_def.should_not == "foo"

	lambda{@o.block_checked_def = "foobar"}.should raise_error
	@o.block_checked_def.should_not == "foobar"

	lambda{@o.block_checked_def = nil}.should raise_error
	@o.block_checked_def.should_not == nil

	lambda{@o.block_checked_int_def = 20}.should raise_error
	@o.block_checked_int_def.should_not == 20

	lambda{@o.block_checked_int_def = nil}.should raise_error
	@o.block_checked_int_def.should_not == nil

    end
end

context "Checked array attribute" do
    setup do
	# Variables: Class, nil, default, block
	my_class = Class.new do
	    array_attr :unchecked
	    array_attr Integer, :int
	    array_attr(:block_checked) { |e|
		    String === e && e.size < 4
		}
	    array_attr Integer, :block_checked_int do |e|
		    e < 10
		end

	end
	@o = my_class.new
    end

    specify "should allow assignment to members (all forms of array)" do
	lambda{
		@o.unchecked[1] = "foo"
	    }.should_not raise_error
	@o.unchecked[1].should == "foo"

	@o.int[0] = 1
	@o.int[0].should == 1

	@o.block_checked[0] = "foo"
	@o.block_checked[0].should == "foo"

	@o.block_checked_int[0] = 7
	@o.block_checked_int[0].should == 7
    end

    specify "should allow assignment of whole array (all forms of array)" do
	lambda{
		@o.unchecked[0] = 0
		@o.unchecked = [ 1, 2, "foo" ]
	    }.should_not raise_error
	@o.unchecked.should == [ 1, 2, "foo" ]

	@o.int = [ 1, 2, 3 ]
	@o.int.should == [ 1, 2, 3 ]

	@o.block_checked = [ "foo", "bar", "baz" ]
	@o.block_checked.should == [ "foo", "bar", "baz" ]

	@o.block_checked_int = [ 5, 6, 7 ]
	@o.block_checked_int.should == [ 5, 6, 7 ]
    end

    specify "should error and leave value unchanged when a member is assigned an invalid value" do
	@o.int[0] = 1
	lambda{
		@o.int[0] = "foo"
	    }.should raise_error
	@o.int.should == [1]

	@o.block_checked[0] = "foo"
	lambda{
		@o.block_checked[0] = "foobar"
	    }.should raise_error
	@o.block_checked[0].should == "foo"

	@o.block_checked_int[0] = 7
	lambda{
		@o.block_checked_int[0] = 17
	    }.should raise_error
	@o.block_checked_int[0].should == 7
    end

    specify "should error and leave value unchanged on assignment of whole array containing an invalid value (all forms of array)" do
	@o.int = [ 1, 2, 3 ]
	lambda{
		@o.int = [ 1, "foo", 3 ]
	    }.should raise_error
	@o.int.should == [ 1, 2, 3 ]

	@o.block_checked = [ "foo", "bar", "baz" ]
	lambda{
		@o.block_checked = [ "foo", "foobar", "baz" ]
	    }.should raise_error
	@o.block_checked.should == [ "foo", "bar", "baz" ]

	@o.block_checked_int = [ 5, 6, 7 ]
	lambda{
		@o.block_checked_int = [ 5, 60, 7 ]
	    }.should raise_error
	@o.block_checked_int.should == [ 5, 6, 7 ]
    end

end
