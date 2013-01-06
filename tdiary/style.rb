module TDiary
	#
	# module SectionBase
	#  Base module of Section.
	#
	module SectionBase

		attr_reader :subtitle, :author
		attr_reader :categories, :stripped_subtitle
		attr_reader :subtitle_to_html, :stripped_subtitle_to_html, :body_to_html

		def body
			@body.dup
		end

		def body=(str)
			@body = str
		end

		def html4(date, idx, opt)
			r = %Q[<div class="section">\n]
			r << %Q[<%=section_enter_proc( Time.at( #{date.to_i} ) )%>\n]
			r << do_html4( date, idx, opt )
			r << %Q[<%=section_leave_proc( Time.at( #{date.to_i} ) )%>\n]
			r << "</div>\n"
		end

		def chtml(date, idx, opt)
			r = %Q[<%=section_enter_proc( Time.at( #{date.to_i} ) )%>\n]
			r << do_html4( date, idx, opt )
			r << %Q[<%=section_leave_proc( Time.at( #{date.to_i} ) )%>\n]
		end

		def to_s
			to_src
		end

		def categories_to_string
			@categories = categories
			cat_str = ""
			categories.each {|cat| cat_str << "[#{cat}]"}
			cat_str << " " unless cat_str.empty?
		end
	end

	#
	# module DiaryBase
	#  Base module of Diary.
	#
	module DiaryBase
		include ERB::Util
		include CommentManager
		include RefererManager

		def init_diary
			init_comments
			init_referers
			@show = true
		end

		def date
			@date
		end

		def set_date( date )
			if date.class == String then
				y, m, d = date.scan( /^(\d{4})(\d\d)(\d\d)$/ )[0]
				raise ArgumentError::new( 'date string needs YYYYMMDD format.' ) unless y
				@date = Time::local( y, m, d )
			else
				@date = date
			end
		end

		def title
			@title || ''
		end

		def set_title( title )
			@title = title
			@last_modified = Time::now
		end

		def last_modified
			@last_modified ? @last_modified : Time::at( 0 )
		end

		def last_modified=( lm )
			@last_modified  = lm
		end

		def visible?
			@show != false;
		end

		def show( s )
			@show = s
		end

		def replace(date, title, body)
			set_date( date )
			set_title( title )
			@sections = []
			append( body )
		end

		def each_section
			@sections.each do |section|
				yield section
			end
		end

		def delete_section(index)
			@sections.delete_at(index - 1)
		end

		def eval_rhtml( opt, path = '.' )
			ERB.new(File.read("#{path}/skel/#{opt['prefix']}diary.rhtml").untaint).result(binding)
		end

		def to_src
			r = ''
			each_section do |section|
				r << section.to_src
			end
			r
		end

		def to_html( opt = {}, mode = :HTML )
			case mode
			when :CHTML
				to_chtml( opt )
			else
				to_html4( opt )
			end
		end

		def to_html4(opt)
			r = ''
			idx = 1
			each_section do |section|
				r << section.html4( date, idx, opt )
				idx += 1
			end
			r
		end

		def to_chtml( opt )
			r = ''
			idx = 1
			each_section do |section|
				r << section.chtml( date, idx, opt )
				idx += 1
			end
			r
		end

		def to_s
			"date=#{date.strftime('%Y%m%d')}, title=#{title}, body=[#{@sections.join('][')}]"
		end
	end

	#
	# module CategorizableDiary
	#
	module CategorizableDiary
		def categorizable?; true; end
	end

	#
	# module UncategorizableDiary
	#
	module UncategorizableDiary
		def categorizable?; false; end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
