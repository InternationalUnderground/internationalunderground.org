# author:: Greg Boone boone.greg@gmail.com
# license:: CC0
module Jekyll
	class FeaturedPostTag < Liquid::Tag
		def initialize(tag_name, value, tokens)
			super
			@count = value.to_i
		end
		def render(context)
			site = context.registers[:site]
			posts = site.posts
			series = context.registers[:site].data['series']
			feature = context.registers[:page]['feature']
			slugs = series[feature]['posts']
			featured_posts = Array.new()
			posts.each { |x| featured_posts.push(x) if slugs.include?(x.slug) }
			post = featured_posts[@count]
			"<h3><a href=\"#{post.url}\">#{post.title}</a></h3><p>#{post.excerpt}<br /><a href=\"#{post.url}\">Continue Reading →</a></p>"
		end
	end
end
Liquid::Template.register_tag('feature_post', Jekyll::FeaturedPostTag)
