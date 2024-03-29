require 'feedjira'

class ScreencastImporter
  def self.import_railscasts

    # because the Railscasts feed is targeted at itunes, there is additional metadata that
    # is not collected by feedjira by default. By using add_common_feed_entry_element,
    # we can let feedjira know how to map those values. See more information at
    # http://www.ruby-doc.org/gems/docs/f/feedjira-0.1.2/feedjira/Feed.html
    Feedjira::Feed.add_common_feed_entry_element(:enclosure, :value => :url, :as => :video_url)
    Feedjira::Feed.add_common_feed_entry_element('itunes:duration', :as => :duration)

    # Capture the feed and iterate over each entry
    feed = Feedjira::Feed.fetch_and_parse("http://feeds.feedburner.com/railscasts")
    feed.entries.each do |entry|

      # Strip out the episode number from the title
      title = entry.title.gsub(/^#\d+\s/, '')

      # Find or create the screencast data into our database
      Screencast.where(video_url: entry.video_url).first_or_create(
        title:        title,
        summary:      entry.summary,
        duration:     entry.duration,
        link:         entry.url,
        published_at: entry.published,
        source:       'railscasts' # set this manually
      )
    end

    # Return the number of total screencasts for the source
    Screencast.where(source: 'railscasts').count
  end
end