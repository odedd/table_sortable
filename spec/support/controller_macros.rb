# spec/support/controller_macros.rb

module ControllerMacros
  def has_before_filters *names
    expect(controller).to have_filters(:before, *names)
  end
end