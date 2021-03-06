class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books
	has_many :favorites, dependent: :destroy
	has_many :book_comments, dependent: :destroy
  attachment :profile_image, destroy: false
  
  
  # ======自分がフォローしているユーザーとの関連 ==============================
  # foreign_key（FK）に@user.relationshipsとした際に@user.idがfollower_idであると指定
  # 親モデルであるRelationshipの外部キーをforeign_keyで設定
  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  # @user.booksのように、@user.followingsで、そのユーザがフォローしている人の一覧を出したい
  # 中間テーブルを介して「followed」モデルのUser(フォローする側)を集めることを「followings」と定義
  has_many :followings, through: :relationships, source: :followed
  # ==============================================================================
  
   # =======自分をフォローしているユーザーとの関連 ========================
  # foreign_key（FK）に@user.reverse_of_relationshipsとした際に@user.idがfollowed_idであると指定
  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :reverse_of_relationships, source: :follower
  # ==================================================================================
  
  def followed?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  
  def follow(user_id)
    relationships.create(followed_id: user_id)
  end

  def unfollow(user_id)
    relationships.find_by(followed_id: user_id).destroy
  end
  
  
    def self.search(search)
      # 検索ワードがある場合
      if search
        User.where(['content LIKE ?', "%#{search}%"])
      else
        User.all
      end
    end

  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates :introduction, length: { maximum: 50 }
  
include JpPrefecture
jp_prefecture :prefecture_code  
# prefecture_codeはuserが持っているカラム

# postal_codeからprefecture_nameに変換するメソッドを用意します．
def prefecture_name
  JpPrefecture::Prefecture.find(code: prefecture_code).try(:name)
end
  
def prefecture_name=(prefecture_name)
  self.prefecture_code = JpPrefecture::Prefecture.find(name: prefecture_name).code
end

end
