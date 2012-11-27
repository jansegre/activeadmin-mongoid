ActiveAdmin::Namespace # autoload
ActiveAdmin::Comment # autoload

# Object.send(:remove_const, "ActiveAdmin::Comment")

module ActiveAdmin
  remove_const :Comment
  class Comment
    include ::Mongoid::Document
    include ::Mongoid::Timestamps

    field :body, type: String
    field :namespace, type: String

    belongs_to :resource, :polymorphic => true
    belongs_to :author, :polymorphic => true

    attr_accessible :resource, :resource_id, :resource_type, :body, :namespace

    validates_presence_of :resource
    validates_presence_of :body
    validates_presence_of :namespace

    # @returns [String] The name of the record to use for the polymorphic relationship
    def self.resource_type(record)
      record.class.name.to_s
    end

    def self.find_for_resource_in_namespace(resource, namespace)
      where(:resource_type => resource_type(resource),
          :resource_id => resource.id,
          :namespace => namespace.to_s)
    end

    def self.resource_id_type
      fiel.select { |i| i.name == "resource_id" }.first.type
    end

    store_in(collection: ActiveRecord::Migrator.proper_table_name("active_admin_comments"))
  end
end

ActiveAdmin::Comments::Views # autoload

module ActiveAdmin
  module Comments
    module Views
      class Comments < ActiveAdmin::Views::Panel
        def build_comment_form
          self << active_admin_form_for(ActiveAdmin::Comment.new, :url => comment_form_url, :html => {:class => "inline_form"}) do |form|
            form.inputs do
              form.input :resource_type, :input_html => { :value => ActiveAdmin::Comment.resource_type(@record) }, :as => :hidden
              form.input :resource_id, :input_html => { :value => @record.id }, :as => :hidden
              form.input :body, :as => :text, :input_html => { :size => "80x8" }, :label => false
            end
            form.actions do
              form.action :submit, :label => I18n.t('active_admin.comments.add'), :button_html => { :value => I18n.t('active_admin.comments.add') }
            end
          end
        end
      end
    end
  end
end

# to disable comments

#class ActiveAdmin::Namespace
#  # Disable comments
#  def comments?
#    false
#  end
#end
