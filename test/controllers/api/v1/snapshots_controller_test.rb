# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class SnapshotsControllerTest < ActionController::TestCase
      let(:user) { users(:random) }

      before do
        @controller = Api::V1::SnapshotsController.new

        login_user user
      end

      describe 'Creates a snapshot' do
        let(:acase)         { cases(:queries_case) }
        let(:first_query)   { queries(:first_query) }
        let(:second_query)  { queries(:second_query) }

        test 'adds snapshot to case' do
          data = {
            snapshot: {
              name: 'New Snapshot',
              docs: {
                first_query.id  => [
                  { id: 'doc1', explain: '1' },
                  { id: 'doc2', explain: '2' }
                ],
                second_query.id => [
                  { id: 'doc3', explain: '3' },
                  { id: 'doc4', explain: '4' }
                ],
              },
            },
          }

          assert_difference 'acase.snapshots.count' do
            post :create, data.merge(case_id: acase.id)

            assert_response :ok

            snapshot = JSON.parse(response.body)

            assert_not_nil snapshot['time']

            assert_equal snapshot['name'],        data[:snapshot][:name]
            assert_equal snapshot['docs'].length, data[:snapshot][:docs].length

            data_doc      = data[:snapshot][:docs][first_query.id][0]
            response_doc  = snapshot['docs'][first_query.id.to_s][0]

            assert_equal data_doc[:id],       response_doc['id']
            assert_equal data_doc[:explain],  response_doc['explain']

            data_doc      = data[:snapshot][:docs][second_query.id][0]
            response_doc  = snapshot['docs'][second_query.id.to_s][0]

            assert_equal data_doc[:id],       response_doc['id']
            assert_equal data_doc[:explain],  response_doc['explain']
          end
        end

        test 'handles queries with no docs' do
          data = {
            snapshot: {
              name: 'New Snapshot',
              docs: {
                first_query.id  => [
                  { id: 'doc1', explain: '1' },
                  { id: 'doc2', explain: '2' }
                ],
                second_query.id => [],
              },
            },
          }

          assert_difference 'acase.snapshots.count' do
            post :create, data.merge(case_id: acase.id)

            assert_response :ok

            snapshot = JSON.parse(response.body)

            assert_equal snapshot['name'],        data[:snapshot][:name]
            assert_equal snapshot['docs'].length, data[:snapshot][:docs].length

            data_doc      = data[:snapshot][:docs][first_query.id][0]
            response_doc  = snapshot['docs'][first_query.id.to_s][0]

            assert_equal data_doc[:id],       response_doc['id']
            assert_equal data_doc[:explain],  response_doc['explain']

            response_docs = snapshot['docs'][second_query.id.to_s]

            assert_empty response_docs
          end
        end

        test 'handles empty list of docs' do
          data = {
            snapshot: {
              name: 'New Snapshot',
              docs: {},
            },
          }

          assert_difference 'acase.snapshots.count' do
            post :create, data.merge(case_id: acase.id)

            assert_response :ok

            snapshot = JSON.parse(response.body)

            assert_equal  snapshot['name'], data[:snapshot][:name]
            assert_nil    snapshot['docs']
          end
        end

        test 'sets name to default if blank' do
          data = {
            snapshot: {
              name: '',
              docs: {
                first_query.id  => [
                  { id: 'doc1', explain: '1' },
                  { id: 'doc2', explain: '2' }
                ],
                second_query.id => [
                  { id: 'doc3', explain: '3' },
                  { id: 'doc4', explain: '4' }
                ],
              },
            },
          }

          assert_difference 'acase.snapshots.count' do
            post :create, data.merge(case_id: acase.id)

            assert_response :ok

            assert_equal json_response['name'], "Snapshot #{Time.zone.now.strftime('%D')}"
          end

          data = {
            snapshot: {
              docs: {
                first_query.id  => [
                  { id: 'doc1', explain: '1' },
                  { id: 'doc2', explain: '2' }
                ],
                second_query.id => [
                  { id: 'doc3', explain: '3' },
                  { id: 'doc4', explain: '4' }
                ],
              },
            },
          }

          assert_difference 'acase.snapshots.count' do
            post :create, data.merge(case_id: acase.id)

            assert_response :ok

            assert_equal json_response(true)['name'], "Snapshot #{Time.zone.now.strftime('%D')}"
          end
        end

        describe 'analytics' do
          let(:acase) { cases(:queries_case) }
          let(:data)  do
            {
              snapshot: {
                name: 'New Snapshot',
                docs: {},
              },
            }
          end

          test 'posts event' do
            expects_any_ga_event_call

            perform_enqueued_jobs do
              post :create, data.merge(case_id: acase.id)

              assert_response :ok
            end
          end
        end
      end

      describe 'Fetches a snapshot' do
        let(:acase)     { cases(:snapshot_case) }
        let(:snapshot)  { snapshots(:a_snapshot) }

        test 'returns full snapshot details' do
          get :show, case_id: acase.id, id: snapshot.id

          assert_response :ok

          data = JSON.parse(response.body)

          assert_equal data['name'],        snapshot.name
          assert_equal data['docs'].length, snapshot.snapshot_queries.length
        end
      end

      describe 'Deletes a snapshot' do
        let(:acase)     { cases(:snapshot_case) }
        let(:snapshot)  { snapshots(:a_snapshot) }

        test 'returns full snapshot details' do
          assert_difference 'acase.snapshots.count', -1 do
            delete :destroy, case_id: acase.id, id: snapshot.id

            assert_response :no_content
          end
        end

        describe 'analytics' do
          test 'posts event' do
            expects_any_ga_event_call

            perform_enqueued_jobs do
              delete :destroy, case_id: acase.id, id: snapshot.id

              assert_response :no_content
            end
          end
        end
      end

      describe 'Fetches case snapshots' do
        let(:acase) { cases(:snapshot_case) }

        test 'returns compact list of snapshots for case' do
          get :index, case_id: acase.id

          assert_response :ok

          data = JSON.parse(response.body)

          assert_equal data['snapshots'].length, acase.snapshots.count
        end
      end
    end
  end
end
