# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, capsules, letters'
    create_accounts
    create_owned_capsules
    create_owned_letters
    add_collaborators
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_capsules.yml")
CAPSULE_INFO = YAML.load_file("#{DIR}/capsules_seed.yml")
CAPSULES_LETTERS_INFO = YAML.load_file("#{DIR}/letters_owner.yml")
LETTER_INFO = YAML.load_file("#{DIR}/letters_seed.yml")
CONTRIB_INFO = YAML.load_file("#{DIR}/letters_collaborators.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    TimeCapsule::Account.create(account_info)
  end
end

def create_owned_capsules
  OWNER_INFO.each do |owner|
    account = TimeCapsule::Account.first(username: owner['username'])
    owner['capsule_names'].each do |capsule_name|
      # to find capsule type
      capsule = CAPSULE_INFO.find { |caps| caps['name'] == capsule_name } # Data Letter == Data Letter

      TimeCapsule::CreateCapsuleForOwner.call(
        owner_id: account.id, capsule_data: capsule # should be the corresponding capsule id
      )
    end
  end
end

def create_owned_letters
  # loop capsules_letters to find owned letters
  CAPSULES_LETTERS_INFO.each do |capsule_info|
    account = TimeCapsule::Account.first(username: capsule_info['username'])
    capsule = TimeCapsule::Capsule.first(owner_id: account.id, name: capsule_info['capsule_name'])
    capsule_info['letters'].each do |letter_title|
      letter = LETTER_INFO.find { |let| let['title'] == letter_title }
      TimeCapsule::CreateLetterForOwner.call(
        capsule_id: capsule.id, letter_data: letter
      )
    end
  end
end

def add_collaborators
  CONTRIB_INFO.each do |contrib_info|
    account = TimeCapsule::Account.first(username: contrib_info['ownername'])
    capsule = TimeCapsule::Capsule.first(owner_id: account.id, name: contrib_info['capsule_name'])
    letter = TimeCapsule::Letter.first(capsule_id: capsule.id, title: contrib_info['title_name'])
    contrib_info['collaborator'].each do |collaborator_email|
      # find collaborator's id, letter_id and join
      TimeCapsule::AddCollaboratorToLetter.call(
        collaborator_email:, letter_data: letter
      )
    end
  end
end
