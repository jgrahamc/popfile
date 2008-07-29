<?cs include "macros.cs" ?>
<?cs include "discussion-macros.cs" ?>

<?cs def:display_group(group, forums) ?>
  <table class="listing">
    <thead>
      <?cs if:group.id ?>
        <tr>
          <th class="group" colspan="6">
            <div class="name"><?cs var:group.name ?></div>
            <div class="description"><?cs var:group.description ?></div>
          </th>
        </tr>
      <?cs /if ?>
      <tr>
        <?cs call:discussion_sortable_th(discussion.order, discussion.asc, 'id', 'ID', discussion.href + '?') ?>
        <?cs call:discussion_sortable_th(discussion.order, discussion.asc, 'subject', 'Forum', discussion.href + '?') ?>
        <?cs call:discussion_sortable_th(discussion.order, discussion.asc, 'lasttopic', 'Last Topic', discussion.href + '?') ?>
        <?cs call:discussion_sortable_th(discussion.order, discussion.asc, 'lastreply', 'Last Reply', discussion.href + '?') ?>
        <?cs call:discussion_sortable_th(discussion.order, discussion.asc, 'topics', 'Topics', discussion.href + '?') ?>
        <?cs call:discussion_sortable_th(discussion.order, discussion.asc, 'replies', 'Replies', discussion.href + '?') ?>
      </tr>
    </thead>
    <tbody>
      <?cs each:forum = forums ?>
        <?cs if forum.group == group.id ?>
          <tr class="<?cs if:name(forum) % #2 ?>even<?cs else ?>odd<?cs /if ?>">
            <td class="id">
              <div class="id">
                <a href="<?cs var:discussion.href ?>/<?cs var:forum.id ?>">
                  <?cs var:forum.id ?>
                </a>
              </div>
            </td>
            <td class="title">
              <div class="subject">
                <a href="<?cs var:discussion.href ?>/<?cs var:forum.id ?>">
                  <?cs alt:forum.subject ?>&nbsp;<?cs /alt ?>
              </a>
              </div>
              <div class="description">
                <a href="<?cs var:discussion.href ?>/<?cs var:forum.id ?>">
                  <?cs alt:forum.description ?>&nbsp;<?cs /alt ?>
                </a>
              </div>
            </td>
            <td class="lasttopic">
              <div class="lasttopic">
                <a href="<?cs var:discussion.href ?>/<?cs var:forum.id ?>">
                  <?cs alt:forum.lasttopic ?>&nbsp;<?cs /alt ?>
              </a>
              </div>
            </td>
            <td class="lastreply">
              <div class="lastreply">
                <a href="<?cs var:discussion.href ?>/<?cs var:forum.id ?>">
                  <?cs alt:forum.lastreply ?>&nbsp;<?cs /alt ?>
              </a>
              </div>
            </td>
            <td class="topics">
              <div class="topics">
                <a href="<?cs var:discussion.href ?>/<?cs var:forum.id ?>">
                  <?cs var:forum.topics ?>
              </a>
              </div>
            </td>
            <td class="replies">
              <div class="replies">
                <a href="<?cs var:discussion.href ?>/<?cs var:forum.id ?>">
                  <?cs var:forum.replies ?>
              </a>
              </div>
            </td>
          </tr>
        <?cs /if ?>
      <?cs /each ?>
    </tbody>
  </table>
<?cs /def ?>

<?cs linclude "discussion-header.cs" ?>
<h1>Forum List</h1>

<?cs if:discussion.forums.0.id ?>
  <?cs each:group = discussion.groups ?>
    <?cs if:group.forums ?>
      <?cs call:display_group(group, discussion.forums) ?>
    <?cs /if ?>
  <?cs /each ?>
<?cs else ?>
  <p class="help">There are no forums created.</p>
<?cs /if ?>

<h2>Monitoring</h2>
<p>If you want to monitor activity on the forums, simply subscribe to the <a type="application/rss+xml" href="/timeline?discussion=on&amp;max=50&amp;daysback=90&amp;format=rss">Forums RSS feed.</a></p>

<?cs if:trac.acl.DISCUSSION_ADMIN ?>
  <form method="post" action="<?cs var:discussion.href ?>">
  <div class="buttons">
      <input type="submit" name="newforum" value="New Forum"/>
      <input type="hidden" name="discussion_action" value="add"/>
    </div>
    </form>
<?cs /if ?>

<?cs linclude "discussion-footer.cs" ?>
