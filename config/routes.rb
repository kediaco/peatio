# frozen_string_literal: true

Peatio::Application.routes.draw do

  get '/swagger', to: 'swagger#index'

  mount({ Mount => Mount::PREFIX }, with: { condition: true })
end
