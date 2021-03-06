feature 'edit note' do

  let (:current_user) { User.create(name: "Hannah", email: "h@h.h", password: "ilovehatsandmops") }
  let (:amanda) { User.create(name: "Amanda", email: "a@a.a", password: "boomboomsand") }
  let (:rachel) { User.create(name: "Rachel", email: "r@r.r", password: "minimalismiscool") }
  let (:admin) { User.create(name: "Lucy", email: "l@l.l", password: "ilovelucy", role: "admin") }
  let (:note_by_current_user) { Note.create(user: current_user, content: "I am happy", visible_to: "#{amanda.name}, #{rachel.name}") }
  let (:note_by_rachel) { Note.create(user: rachel) }

  scenario 'guest cannot edit a note' do
      visit edit_note_path(note_by_current_user)
      expect(page).to have_content('Access denied.')
  end

  scenario 'user cannot edit a note that is not theirs' do
      login_as(current_user)

      visit edit_note_path(note_by_rachel)
      expect(page).to have_content('Access denied.')
  end

  scenario 'user can edit their own note' do
    login_as(current_user)

    visit edit_note_path(note_by_current_user)
    expect(page).to have_selector('form')
  end

  scenario 'user can update their own note' do
      login_as(current_user)

      visit edit_note_path(note_by_current_user)
      fill_in 'note_content', :with => 'I am a teapot'
      fill_in 'note_visible_to', :with => "#{rachel.name}"
      click_button 'save'

      expect(page).to have_text('I am a teapot')
      expect(page).to have_text(rachel.name)
      expect(page).not_to have_text(amanda.name)
  end

  scenario 'admin can edit a note that is not theirs' do
      login_as(admin)

      visit edit_note_path(note_by_current_user)
      expect(page).to have_selector('form')
  end

  scenario 'admin can update a note that is not theirs' do
    login_as(admin)

    visit edit_note_path(note_by_current_user)
    fill_in 'note_content', :with => 'I am so happy to be here'
    fill_in 'note_visible_to', :with => "#{rachel.name}, #{amanda.name}"
    click_button 'save'

    expect(page).to have_text('I am so happy to be here')
    expect(page).to have_text(rachel.name)
    expect(page).to have_text(amanda.name)
    expect(page).not_to have_text(admin.name)
  end

end
