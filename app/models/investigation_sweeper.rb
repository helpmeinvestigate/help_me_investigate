class InvestigationSweeper < ActionController::Caching::Sweeper
  observe Investigation # This sweeper is going to keep an eye on the Investigation model

  # If our sweeper detects that a Investigation was created call this
  def after_create(investigation)
    expire_cache_for(investigation)
  end
  
  # If our sweeper detects that a Investigation was updated call this
  def after_update(investigation)
    expire_cache_for(investigation)
  end
  
  # If our sweeper detects that a Investigation was deleted call this
  def after_destroy(investigation)
    expire_cache_for(investigation)
  end
          
  private
  def expire_cache_for(record)
    # Expire the home page
    expire_action(:controller => 'base', :action => 'site_index')

    # Expire the footer content
    expire_action(:controller => 'base', :action => 'footer_content')
    
    # Also expire the sitemap
    expire_action(:controller => 'sitemap', :action => 'index')

    # Expire the category pages
    expire_action(:controller => 'categories', :action => 'show')

    # Also expire the show pages, in case we just edited a blog entry
    expire_action(:controller => 'investigations', :action => 'show')
    
    # Also expire the show pages, in case we just edited a blog entry
    expire_action(:controller => 'investigations', :action => 'index')
  end
end