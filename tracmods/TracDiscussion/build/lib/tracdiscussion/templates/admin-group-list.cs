<?cs include "discussion-macros.cs" ?>

<h2>Forum Groups</h2>

<?cs if:discussion.group.id && !args.submit ?>
  <form id="edit-group-form" class="addnew" method="post" action="<?cs var:discussion.href ?>/group">
    <fieldset>
      <legend>
        Edit Forum Group:
      </legend>
      <div class="field">
        <label for="name">Name:</label><br/>
        <input type="text" name="name" value="<?cs var:discussion.name ?>"/><br/>
      </div>
      <div class="field">
        <label for="description">Description:</label><br/>
        <input type="text" name="description" value="<?cs var:discussion.description ?>"/><br/>
      </div>
      <div class="buttons">
        <input type="submit" name="submit" value="Edit"/>
        <input type="button" name="cancel" value="Cancel" onclick="location.href = '<?cs var:discussion.href ?>/group'"/>
        <input type="hidden" name="group" value="<?cs var:discussion.group.id ?>"/>
        <input type="hidden" name="discussion_action" value="post-edit"/>
      </div>
    </fieldset>
  </form>
<?cs else?>
  <form id="new-group-form" class="addnew" method="post" action="<?cs var:discussion.href ?>/group">
    <fieldset>
      <legend>
         Add Forum Group:
      </legend>
      <div class="field">
        <label for="name">Name:</label><br/>
        <input type="text" name="name" value=""/><br/>
      </div>
      <div class="field">
        <label for="description">Description:</label><br/>
        <input type="text" name="description" value=""/><br/>
      </div>
      <div class="buttons">
        <input type="submit" name="submit" value="Add"/>
        <input type="hidden" name="discussion_action" value="post-add"/>
      </div>
    </fieldset>
  </form>
<?cs /if ?>

<?cs if:discussion.groups.1.id ?>
  <form method="post" action="<?cs var:discussion.href ?>/group">
    <table id="group-list" class="listing">
      <thead>
        <tr>
          <th class="sel">&nbsp;</th>
          <?cs call:discussion_sortable_th(discussion.order, discussion.desc, 'id', 'ID', discussion.href + '/group' + '?') ?>
          <?cs call:discussion_sortable_th(discussion.order, discussion.desc, 'name', 'Name', discussion.href + '/group' + '?') ?>
          <?cs call:discussion_sortable_th(discussion.order, discussion.desc, 'description', 'Description', discussion.href + '/group' + '?') ?>
        </tr>
      </thead>
      <tbody>
        <?cs each:group = discussion.groups ?>
          <?cs if:group.id ?>
            <tr class="<?cs if:name(group) % #2 ?>even<?cs else ?>odd<?cs /if ?>">
              <td class="sel">
                <input type="checkbox" name="selection" value="<?cs var:group.id ?>"/>
              </td>
              <td class="id">
                <a href="<?cs var:discussion.href ?>/group/<?cs var:group.id ?>">
                  <div class="id"><?cs var:group.id ?></div>
                </a>
              </td>
              <td class="name">
                <a href="<?cs var:discussion.href ?>/group/<?cs var:group.id ?>">
                  <div class="name"><?cs alt:group.name ?>&nbsp;<?cs /alt ?></div>
                </a>
              </td>
              <td class="description">
                <a href="<?cs var:discussion.href ?>/group/<?cs var:group.id ?>">
                  <div class="description" ><?cs alt:group.description ?>&nbsp;<?cs /alt ?></div>
                </a>
              </td>
            </tr>
          <?cs /if ?>
        <?cs /each ?>
      </tbody>
    </table>
    <div class="buttons">
      <input type="submit" name="remove" value="Remove selected items" />
      <input type="hidden" name="discussion_action" value="delete"/>
    </div>
  </form>
<?cs else ?>
  <p class="help">As long as you don't add any items to the list, this field
  will remain completely hidden from the user interface.</p>
  <br style="clear: right"/>
<?cs /if ?>
