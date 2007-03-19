=begin rdoc
# Checked arrays and checked attributes (and array attributes) support
# * class-checking (values must be of specified class),
# * allow or deny nil values
# * a block for checking validity of values
#
# Author: Clifford Heath.
=end

=begin rdoc
call-seq:
    Array(class).new                                        -> array
    class MyClass < Array(class); end
    class MyClass < Array class do |elem| elem.isvalid end
    class MyClass < Array {|elem| elem.respond_to?(:meth) }

Checked array classes are subclasses of #Array
that are created using this <tt>Array()</tt> method.
They provide two kinds of checking on values entered into the array:
* class checking (using kind_of?)
* calling a block to determine validity

When any value is entered into the Array, by any method,
that doesn't satisfy your checks, you'll get a nice exception.
Beware of catching this exception, as in some cases
(+flatten+ for instance) the operation has been completed
before the new array value is checked and the exception raised.

Here's a simple example:
    int_array = Array(Integer).new
    int_array << 4
    int_array.concat [ 6, 8, 10 ]
    int_array << "Oops"                 # This will raise an exception

Surprisingly, a call to <tt>Array()</tt> works even as a superclass in a new class definition:
    class MyArray < Array(Integer)
        def my_meth()
            ...
        end
    end

and you can even use both together. An exception is raised if the block returns false/nil:
    class MyArray < Array(Integer) {|i|
            (0..5).include?(i)          # Value must be an integer from 0 to 5
        }
    end
    MyArray.new << 6                    # This will raise an exception

The parameter to Array is optional, which removes the class check.
You can use this to implement type checking that's all your own:
    class MyArray < Array {|i|
            i.respond_to?(:+@) && i.respond_to(:to_i)
        }
        def my_meth()
        end
    end

Note that these latter examples create _two_ new classes,
one from the call to the Array() method, and one that you declared.
So you don't need to worry about overriding the methods that perform
the checking; +super+ works as normal.

There is no way to specify an initial size or a default value.

The methods that are overridden in order to implement the checking are
listed below. All documented types of parameter lists and blocks are supported.
- new
- Array.[] (constructor)
- []=
- <<
- concat
- fill
- flatten!
- replace
- insert
- collect!
- map!
- push

=end
def Array(type = nil, &block)
    Class.new(Array).class_eval <<-END
	    if (Class === type)
	        @@_valid_type = lambda{|o| o.kind_of?(type) && (!block || block.call(o)) }
	    else
	        @@_valid_type ||= (block || lambda{|o| true})
	    end

	    def self.new(*a, &b)
		r = super()	# Is this correct?
		if (a.size == 1 && a[0].class != Fixnum)
		    r.concat(a[0])
		elsif (b)
		    raise "Wrong number of parameters for Array.new" if a.size != 1
		    (0...a[0]).each{|i|
			v = b.call(i)
			raise "Illegal array member from block initializer: \#{v.inspect}" unless @@_valid_type.call(v)
			r[i] = v
		    }
		else
		    v = a[1] || nil
		    if (a[1])
			raise "Illegal array member initializer: \#{v.inspect}" unless @@_valid_type.call(v)
		    end
		    if (a.size > 0)
			(0...a[0]).each_index{|i|
			    r[i] = v
			}
		    end
		end
		r
	    end

	    def self.[](*a)
		r = self.new
		r.concat(a)
	    end

	    def []=(*args)
		element = args.last
		raise "Illegal array member assignment: \#{element.inspect}" unless @@_valid_type.call(element)
		super(*args)
	    end

	    def <<(element)
		raise "Illegal array member append: \#{element.inspect}" unless @@_valid_type.call(element)
		super(element)
	    end

	    def concat(other)
		other.each{|e|
		    raise "Illegal array member in concat: \#{e.inspect}" unless @@_valid_type.call(e)
		}
		super(other)
	    end

	    def fill(*a, &b)
		unless b
		    v = a.shift
		    raise "Illegal array value fill: \#{v.inspect}" unless @@_valid_type.call(v)
		    b = lambda{|i| v}
		end

		case a.size
		when 0	    # Fill all members:
		    self.each_index{|i|
			e = b.call(i)
			self[i] = e
		    }
		when 1	    # Fill start..end or using Range:
		    r = a[0]
		    r = (a[0]..self.size-1) unless r.kind_of?(Range)
		    r.each{|i|
			e = b.call(i)
			raise "Illegal array block fill: \#{e.inspect}" unless @@_valid_type.call(e)
			self[i] = e
		    }
		when 2
		    start = a[0]
		    a[0] = Range.new(start, start+a.pop)
		end
		self
	    end

	    def check_valid(operation)
		each{|e|
		    raise "Illegal array element: \#{e.inspect} after \#{operation}" unless @@_valid_type.call(e)
		}
	    end

	    def flatten!()
		saved = clone
		a = super
		begin
		    check_valid "flatten!"
		rescue
		    clear
		    concat saved
		    raise
		end
		a
	    end

	    def replace(a)
		saved = clone
		begin
		    clear
		    concat(a)
		rescue
		    clear   # Restore the value
		    concat saved
		    raise
		end
		self
	    end

	    def insert(*a)
		start = a.shift
		a.each{|e|
		    raise "Illegal array element insert: \#{e.inspect}" unless @@_valid_type.call(e)
		}
		super(start, *a)
	    end

	    def collect!
		each_with_index{|e, i|
		    v = yield(e)
		    raise "Illegal array element in collect!: \#{v.inspect}" unless @@_valid_type.call(v)
		    self[i] = v
		}
		self
	    end

	    def map!(&b)
		collect!(&b)
	    end

	    def push(*a)
		concat a
		self
	    end

            self
	END
end

=begin rdoc
The checked attribute methods are added to Module.
You can use them as a safer replacement for +attr_accessor+.
=end

class Module

=begin rdoc
call-seq:
    typed_attr :attr
    typed_attr nil, :attr
    typed_attr Class, :attr
    typed_attr Class, nil, 'default', :attr
    typed_attr Class, nil, :attr do |val| val.isvalid end
    typed_attr(Integer, 0, :attr) {|val| (0..5).include?(val) }
    ... and combinations

typed_attr is like attr_accessor,
but with optional value checking using either _class_.kind_of? or by calling your block,
or both. Assignment of any value that fails the checks causes an assertion to be raised.

The parameter list is processed in order, and may contain:
- a class. The following attributes will require values that are <tt>kind_of?</tt> this class
- +nil+. Adding +nil+ to the argument list allows +nil+ as a value for the following
  attributes, which otherwise would disallow +nil+,
- a Symbol, which is used as the name for an attribute,
- any other value, which is used as a default value for following attributes.

In addition, typed_attr may be given a block.
Any value to be assigned will be passed to this block,
which must not return false/nil or an exception will be raised.
You'll need to parenthesize the parameter list for a {|| } block,
or just use a do...end block.

Here's an example:
    class MyClass
        typed_attr nil, :attr1          # This attribute is unchecked
        typed_attr :attr2               # This attribute may be assigned any non-nil value
        typed_attr String, "hi", :attr3 # This attribute must be a string and defaults to "hi"
        typed_attr Integer, 0, :attr4 do |i|
                (0..5).include?(i)      # This attribute must be an Integer in 0..5
            end
        typed_attr String, :foo, Integer, :bar # Two attributes of different types. Don't do this please!
        typed_attr(String, :attr5) {|s|
                s.size >= 4             # Values must have at least 4 characters
            }
    end

Note that if you don't allow nil, you should use a default value,
or a new object will break your rules. This won't cause an exception,
as typed_attr assumes you'll initialise the value in the object's
constructor.

=end
    def typed_attr(*names, &block)
	klass = Object
	nil_ok = false
	def_val = nil

	names.each{|name|
	    case name
	    when Class
		klass = name
	    when NilClass
		nil_ok = true
	    when Symbol
		define_method(name) { 
		    v = instance_variable_get("@#{name}")
		    # This is awkward if nil is a valid value:
		    if (v == nil && (!nil_ok || !instance_variables.include?("@#{name}")))
			v = instance_variable_set("@#{name}", def_val)
		    end
		    v
		}
		define_method("#{name}=") {|val|
		    if val == nil
			unless nil_ok
			    raise "Can't assign nil to #{name} which is restricted to class #{klass}"
			end
		    else
			if !val.kind_of?(klass)
			    raise "Can't assign #{val.inspect} of class #{val.class} to attribute #{name} which is restricted to class #{klass}"
			elsif (block && !block.call(val))
			    raise "Invalid value assigned to #{name}: #{val.inspect}"
			end
		    end
		    instance_variable_set("@#{name}", val)
		}
	    else
		def_val = name	    # Save this as a default value
	    end
	}
    end

=begin rdoc
call-seq:
    array_attr :attr
    array_attr Class, :attr, Class2, :attr2
    array_attr Class, :attr do |val| val.isvalid end
    array_attr(:attr) {|val| val.isvalid }

array_attr is like attr_accessor, but the attributes it creates are checked Arrays, see checked Array.

The parameter list is processed in order, and may contain:
- a class. The following array attributes will require values that are <tt>kind_of?</tt> this class
- a Symbol, which is used as the name for an array attribute.

In addition, array_attr may be given a block.
Any value to be used as a member of the array will be passed to this block,
which must not return false/nil or an exception will be raised.
You'll need to parenthesize the parameter list for a {|| } block,
or just use a do...end block.

There's no need to initialize the attribute with an empty array, that comes for free.

nil checking and default values are not provided as with +typed_attr+.

Here's an example:
    class MyClass
        array_attr String, :attr1 do|s|
                s.size >= 5             # All array members must have >=5 characters
            end
        array_attr(:attr2) {|e|         # Array members must be Integers or Strings
                e.kind_of?(String) || e.kind_of?(Integer)
            }
    end

    c = MyClass.new
    c.attr1 << "ouch"                   # Error, string is too short
    c.attr2 << { :hi => "there" }       # Error, value must be Integer or String
=end
    def array_attr(*names, &block)
	klass = Object
	names.each{|name|
	    case name
	    when Class
		klass = name
	    when Symbol
		define_method(name) { 
		    instance_variable_get("@#{name}") ||
			instance_variable_set("@#{name}", Array(klass, &block).new)
		}
		define_method("#{name}=") {|val|
		    a = instance_variable_get("@#{name}") ||
			instance_variable_set("@#{name}", Array(klass, &block).new)
		    saved = a.clone
		    a.clear
		    begin
			a.concat(val)   # If conversion is legal, this will do it
		    rescue
			instance_variable_set("@#{name}", saved)
			raise
		    end
		}
	    else
		raise "Parameter to array_attr must be Class or Symbol"
	    end
	}
    end
end
