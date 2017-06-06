# coding: utf-8
class Contact < ActiveRecord::Base
  has_many :phones
  accepts_nested_attributes_for :phones

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :email, presence: true, uniqueness: true

  # 返回名字全称
  def name
    [firstname, lastname].join(' ')
  end

  # 返回姓名字母的模糊查询
  def self.by_letter(letter)
    where("lastname LIKE ?", "#{letter}%").order(:lastname)
  end
end
