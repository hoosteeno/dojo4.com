Rails.application.routes.draw do
  
  get '*_/media/*path', :format => false, :to => redirect('/media/%{path}')

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root :to => 'site#index'

end
