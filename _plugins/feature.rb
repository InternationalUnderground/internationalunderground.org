# author:: Greg Boone boone.greg@gmail.com
# license:: CC0
module Jekyll
	
	class SeriesHelper
		
		def initialize(site)
			@posts = site.posts
			@feature = site.collections['feature'].docs
		end

		# Returns the series document matching a given slug
		def series_by_slug(slug)
			feature = @feature
			return feature.find { |feature| feature.data['slug'] == slug }
		end

		# gets the feature corresponding to a post
		def series_from_post(slug)
			feature = @feature
			return feature.find { |feature| feature.data['posts'].include?(slug) }
		end
		def get_page_slug(page)
			return page['url'].split('/')[2]
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
			helper =  SeriesHelper.new(context.registers[:site])
			series = helper.series_from_post(post)
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
			helper = SeriesHelper.new(site)
			slug = site.config['featured_series']
			series = helper.series_by_slug(slug)
			post = posts.find { |post| post.slug == series.data['posts'][@count-1] }
			"<h3><a href=\"#{post.url}\">#{post.title}</a></h3>
			<p>#{post.excerpt}<br />
			<a href=\"#{post.url}\">Continue reading →</a></p>"
		end
	end

	class CurrentSeriesTag < Liquid::Tag
		def initialize(tag_name, value, tokens)
			super
			@value = value.strip
		end
		def render(context)
			value = @value
			page = context.registers[:page]
			helper = SeriesHelper.new(context.registers[:site])
			slug = helper.get_page_slug(page)
			series = helper.series_from_post(slug)
			unless series.nil?
				title = series.data['title']
				url = series.data['slug']
			end
			if value == "title"
				return title
			elsif value == "url"
				return url
			elsif series.nil?
				return context.registers[:site].data['title']
			else
				return series
			end
		end
	end
end
Liquid::Template.register_tag('related_post', Jekyll::RelatedPostTag)
Liquid::Template.register_tag('post_series', Jekyll::PostSeriesTag)
Liquid::Template.register_tag('current_series', Jekyll::CurrentSeriesTag )