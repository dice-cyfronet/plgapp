module ApplicationHelper
  def current_module?(*args)
    args.any? do |v|
      v.to_s.downcase == controller.class.name.deconstantize.downcase
    end
  end

  # Check if a particular controller is the current one
  #
  # args - One or more controller names to check
  #
  # Examples
  #
  #   # On TreeController
  #   current_controller?(:tree)           # => true
  #   current_controller?(:commits)        # => false
  #   current_controller?(:commits, :tree) # => true
  def current_controller?(*args)
    controller_name = module_prefix + controller.controller_name
    args.any? { |v| v.to_s.downcase == controller_name }
  end

  # Check if a partcular action is the current one
  #
  # args - One or more action names to check
  #
  # Examples
  #
  #   # On Projects#new
  #   current_action?(:new)           # => true
  #   current_action?(:create)        # => false
  #   current_action?(:new, :create)  # => true
  def current_action?(*args)
    args.any? { |v| v.to_s.downcase == action_name }
  end

  def show_flash?
    alert != t('devise.failure.unauthenticated')
  end

  def time_ago_with_tooltip(date, placement = 'top', html_class = 'time_ago')
    capture_haml do
      haml_tag :time, date.to_s,
               class: html_class,
               datetime: date.getutc.iso8601,
               title: date.in_time_zone.stamp('Aug 21, 2011 9:23pm'),
               data: { toggle: 'tooltip', placement: placement },
               lang: I18n.locale

      haml_tag :script, "$('." + html_class + "').timeago().tooltip()"
    end.html_safe
  end

  private

  def module_prefix
    module_name = controller.class.name.deconstantize.downcase

    module_name == '' ? '' : "#{module_name}_"
  end
end
