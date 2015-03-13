# author:: Greg Boone boone.greg@gmail.com
# license:: CC0
module Jekyll
	
	class CollectionHelper
		
		def initialize(site, collection)
			@posts = site.posts
			@collection = collection
			@docs = site.collections[collection].docs
		end

		# Returns the collection document matching a given slug
		def document_by_name(name)
			docs = @docs
			return docs.find { |doc| doc.data['slug'] == name }
		end

		# gets the collection document corresponding to a post
		def document_from_post(name)
			docs = @docs
			return docs.find { |doc| doc.data['posts'].include?(name) }
		end
		
		# returns the name from a page object
		# for some reason jekyll doesn't include 'name' in context.registers[:page]
		def get_page_name(page)
			return page['url'].split('/')[2]
		end
		# returns true if a page slug matches a series
		# this might not be sustainable if a post within a series shares the name
		# with the series. For example, if we have a series named the-wire and a post
		# inside the series _also_ called the-wire and this method is called with
		# either post.name or collection.name it will return true. I'm not sure how
		# frequently that will happen because you can probably use other contexts. It
		# was originally written to determine whether a given page is a series or not.
		def is_series?
		end
	end

	class PostSeriesTag < Liquid::Tag
		def initialize(tag_name, value, tokens)
			@tag_name = tag_name
			@value = value
			@tokens = tokens
		end
		def render(context)
			post = context.scopes[0]['post'].slug
			helper =  CollectionHelper.new(context.registers[:site], 'feature')
			series = helper.document_from_post(post)
			"Series: <a href=\"#{series.url}\">#{series.data['title']}</a>" unless series.nil?
		end
	end

	class RelatedPostTag < Liquid::Tag
		def initialize(tag_name, value, tokens)
			super
			@count = value.to_i
		end
		
		def render(context)
			site = context.registers[:site]
			posts = site.posts
			helper = CollectionHelper.new(site, 'feature')
			slug = site.config['featured_series']
			series = helper.document_by_name(slug)
			post = posts.find { |post| post.slug == series.data['posts'][@count-1] }
			"<h3><a href=\"#{post.url}\">#{post.title}</a></h3>
			<p>#{post.excerpt}<br />
			<a href=\"#{post.url}\">Continue reading →</a></p>"
		end
	end

	class SeriesTitleTag < Liquid::Tag
		def initialize(tag_name, value, tokens)
			super
			@value = value.strip
		end
		def render(context)
			page = context.registers[:page]
			site = context.registers[:site]
			helper = CollectionHelper.new(site, 'feature')
			slug = helper.get_page_name(page)
			series = helper.document_from_post(slug)
			unless series.nil?
				title = series.data['title']
				slug = series.data['slug']
			end
			if @value == 'slug'
				return slug unless series.nil?
			elsif @value == 'title'
				return title unless series.nil?
			end
		end
		# end SeriesTitleTag class
	end

	class PostTitleTag < Liquid::Tag
			# This is a class written to help relate posts and collections. It assumes,
			# like other classes in this plugin, that you define which posts belong to 
			# collection in the collection document's front matter.
			#
			# Given a collection "series," define a `posts` entry in the front matter:
			# ```
			# posts:
			# - post-name
			# - post-name
			# ```
			def initialize(tag_name, value, tokens)
				super
				@tag = tag_name.strip
				@value = value.strip
			end

			# Grabs post information for posts in collection @value
			# 
			# Assumes you are rendering a colleciton document
			def render(context)
				tag = @tag.split('_')[1]
				value = @value
				page = context.registers[:page]
				@site = context.registers[:site]
				post = context.scopes[0]['post']
				posts = @site.posts
				helper = CollectionHelper.new(@site, page['collection'])
				post_object = posts.find { |p| p.slug ==  post}
				answer = get_post_part(post_object, tag, value)
				return answer
				# if @tag == "post_title"
				# 	require 'pry'; binding.pry
				# 	return post_object.title
				# elsif @tag == "post_date"
				# 	return post_object.date
				# elsif @tag == "post_author"
				# 	return post_object.data['author']
				# elsif @tag == "post_excerpt"
				# 	return post_object.excerpt
				# else
				# 	return post_object
				# end
			end

			def get_post_part(post, tag, value)
				if tag == "author"
					author = @site.data['authors'].find { |a| a['name'] == post.data['author'][0] }
					return author[value]
				elsif tag == "title"
					return post.title
				elsif tag == "date"
					return post.date.strftime(value)
				elsif tag == "url"
					return post.url
				else tag == "excerpt"
					return post.excerpt
				end
			end
		end
	# end module jekyll
end

Liquid::Template.register_tag('related_post', Jekyll::RelatedPostTag)
Liquid::Template.register_tag('post_series', Jekyll::PostSeriesTag)
Liquid::Template.register_tag('series_title', Jekyll::SeriesTitleTag)
Liquid::Template.register_tag('post_title', Jekyll::PostTitleTag)
Liquid::Template.register_tag('post_date', Jekyll::PostTitleTag)
Liquid::Template.register_tag('post_author', Jekyll::PostTitleTag)
Liquid::Template.register_tag('post_url', Jekyll::PostTitleTag)
Liquid::Template.register_tag('post_excerpt', Jekyll::PostTitleTag)
