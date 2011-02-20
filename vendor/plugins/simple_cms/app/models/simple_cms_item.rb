class SimpleCmsItem < ActiveRecord::Base
  acts_as_versioned

  def label
    h = YAML.load(params)
    h.each do |a|
      return a[1] if a[0] == "label"
    end
    return nil
    #return h["label"]
  end

  def domain
    h = YAML.load(params)
    h.each do |a|
      return a[1] if a[0] == "domain"
    end
    return nil
  end

  def controller
    h = YAML.load(params)
    h.each do |a|
      return a[1] if a[0] == "controller"
    end
    return nil
  end

  def action
    h = YAML.load(params)
    h.each do |a|
      return a[1] if a[0] == "action"
    end
    return nil
  end

  def path
    h = YAML.load(params)
    h.each do |a|
      return a[1].join("/") if a[0] == "path"
    end
    return nil
  end
end
