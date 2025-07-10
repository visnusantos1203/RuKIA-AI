class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :documents, dependent: :destroy
  has_many :messages, through: :documents
  has_many :llm_responses, through: :messages

  def jwt_payload
    super
  end
end
