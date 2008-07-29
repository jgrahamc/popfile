<?cs include "macros.cs" ?>
<?cs include "discussion-macros.cs" ?>

<?cs include "discussion-header.cs" ?>

<h1><?cs var:discussion.forum.name ?> - Topic List</h1>
<h2><?cs var:discussion.forum.subject ?></h2>
<p><?cs var:discussion.forum.description ?></p>
<?cs if:discussion.topics.0.id ?>
<p>There are <?cs var:discussion.topic_count ?> topics in this forum</p>
  <table class="listing">
    <thead>
      <tr>
        <?cs call:discussion_sortable_th(discussion.order, discussion.asc, 'id', 'ID', discussion.href + '/' + discussion.forum.id + '?') ?>
        <?cs call:discussion_sortable_th(discussion.order, discussion.asc, 'subject', 'Subject', discussion.href + '/' + discussion.forum.id + '?') ?>
        <?cs call:discussion_sortable_th(discussion.order, discussion.asc, 'author', 'Author', discussion.href + '/' + discussion.forum.id + '?') ?>
        <?cs call:discussion_sortable_th(discussion.order, discussion.asc, 'lastreply', 'Last Reply', discussion.href + '/' + discussion.forum.id + '?') ?>
        <?cs call:discussion_sortable_th(discussion.order, discussion.asc, 'replies', 'Replies', discussion.href + '/' + discussion.forum.id + '?') ?>
      </tr>
    </thead>
    <tbody>
      <?cs each:topic = discussion.topics ?>
        <tr class="<?cs if:name(topic) % #2 ?>even<?cs else ?>odd<?cs /if ?>">
          <td class="id">
            <div class="id">
              <a href="<?cs var:discussion.href ?>/<?cs var:discussion.forum.id ?>/<?cs var:topic.id ?>">
                <?cs var:topic.id ?>
              </a>
            </div>
          </td>
          <td class="subject">
            <div class="subject">
              <a href="<?cs var:discussion.href ?>/<?cs var:discussion.forum.id ?>/<?cs var:topic.id ?>">
                <?cs alt:topic.subject ?>&nbsp;<?cs /alt ?>
              </a>
            </div>
          </td>
          <td class="author">
            <div class="author" >
              <a href="<?cs var:discussion.href ?>/<?cs var:discussion.forum.id ?>/<?cs var:topic.id ?>">
                <?cs alt:topic.author ?>&nbsp;<?cs /alt ?>
              </a>
            </div>
          </td>
          <td class="lastreply">
            <div class="lastreply">
              <a href="<?cs var:discussion.href ?>/<?cs var:discussion.forum.id ?>/<?cs var:topic.id ?>">
                <?cs alt:topic.lastreply ?>&nbsp;<?cs /alt ?>
              </a>
            </div>
          </td>
          <td class="replies">
            <div class="replies" >
              <a href="<?cs var:discussion.href ?>/<?cs var:discussion.forum.id ?>/<?cs var:topic.id ?>">
                <?cs var:topic.replies ?>
              </a>
            </div>
          </td>
        </tr>
      <?cs /each ?>
    </tbody>
  </table>
<?cs else ?>
  <p class="help">There are no topics created in this forum.</p>
<?cs /if ?>

<table width="100%" border="0" cellpadding="1" cellspacing="0" style="margin-top: 10px">
    <tr style="background-color: #eee">
        <td style="text-align: left">
            <?cs if:discussion.prev_page != '' ?><a href="?start=<?cs var:discussion.prev_page ?>&amp;order=<?cs var:discussion.order ?>&amp;asc=<?cs var:discussion.asc ?>">&lt; previous page</a><?cs /if ?>
        </td>
        <td style="text-align: right">
            <?cs if:discussion.next_page != '' ?><a href="?start=<?cs var:discussion.next_page ?>&amp;order=<?cs var:discussion.order ?>&amp;asc=<?cs var:discussion.asc ?>">next page &gt;</a><?cs /if ?>
        </td>
    </tr>
</table>

<?cs if:trac.acl.DISCUSSION_APPEND ?>
  <form method="post" action="<?cs var:discussion.href ?>/<?cs var:discussion.forum.id ?>">
    <div class="buttons">
      <input type="submit" name="newtopic" value="New Topic"/>
      <input type="hidden" name="forum" value="<?cs var:discussion.forum.id ?>"/>
      <input type="hidden" name="discussion_action" value="add"/>
    </div>
  </form>
<?cs /if ?>
<?cs if:trac.acl.DISCUSSION_ADMIN ?>
  <form method="post" action="<?cs var:discussion.href ?>">
    <div class="buttons">
      <input type="submit" name="deleteforum" value="Delete Forum" onclick="return confirm('Do you realy want to delete this forum?')"/>
      <input type="hidden" name="forum" value="<?cs var:discussion.forum.id ?>"/>
      <input type="hidden" name="discussion_action" value="delete"/>
    </div>
  </form>
<?cs /if ?>

<?cs include "discussion-footer.cs" ?>
