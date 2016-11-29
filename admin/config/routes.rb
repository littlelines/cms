PushType::Admin::Engine.routes.draw do

  scope module: 'admin' do

    resources :nodes, except: :show do
      collection do
        get 'trash'
        delete 'trash' => 'nodes#empty'
      end
      member do
        post 'position'
        put 'restore'
      end
      resources :nodes, only: [:index, :new, :create]
    end

    resources :assets, path: 'media' do
      collection do
        post 'upload'
        get 'trash'
        delete 'trash' => 'assets#empty'
      end
      member do
        get 'download'
        put 'restore'
      end
    end

    resources :users, except: :show
    resources :inquiries, only: [:index, :show]
  end

  get 'info' => 'admin#info', as: 'info'
  root to: redirect('nodes')

end
