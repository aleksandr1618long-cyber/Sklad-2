/*
# QR: общие поломки и файлы комментариев/поломок

1. Проблема
- Комментарии квартиры видны всем активным (006), но их фото/видео лежали в incident-photos
  и читались только владельцем папки или админом: у остальных "файл недоступен".
- Поломки по квартире видел только их автор (created_by = auth.uid()).

2. Изменения
- incidents: SELECT для любого активного пользователя (запись по-прежнему только от своего имени).
- storage incident-photos: SELECT для админа и любого активного пользователя.
  Загрузка (INSERT) остаётся только в свою папку <uid>/..., cleaning-media не меняется.

3. Безопасность
- Доступны только авторизованные активные пользователи; anon не имеет доступа.
- Изменять и удалять чужое по-прежнему нельзя.
*/

DROP POLICY IF EXISTS sv_incidents_read ON public.incidents;
CREATE POLICY sv_incidents_read ON public.incidents FOR SELECT
  TO authenticated
  USING (is_active_user());

DROP POLICY IF EXISTS "incident_photos_read_active" ON storage.objects;
CREATE POLICY "incident_photos_read_active"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'incident-photos'
  AND (is_admin() OR is_active_user())
);
